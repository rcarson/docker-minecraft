#!/usr/bin/env bash
#
#

set -e

function usage {
    echo "Usage: $(basename $0) [OPTION]..."
    echo "Build the minecraft docker image"
    echo ""
    echo "  -h, --help               This message."
    echo "  --snapshot               The release type to build (snapshot, default: release)"
    echo "  --version                The version to build"
    echo ""

}

TYPE='release'

while [[ $# -gt 0 ]]; do
    case $1 in
	    -h|--help) usage; exit 1;;
        --snapshot) TYPE='snapshot';;
	    --version) version="$2"; shift;;
    esac
    shift
done

if [[ -z "${version:-}" ]]; then
    # get latest release version
    #version=$(curl -fsSL https://launchermeta.mojang.com/mc/game/version_manifest.json \
    #    | python -c "import sys, json; print(json.load(sys.stdin)[\"latest\"][\"$TYPE\"])")
    version="$(curl -fsSL https://launchermeta.mojang.com/mc/game/version_manifest.json | jq -r .latest.${TYPE})"
fi

echo "-+ Build Version: $version ($TYPE)"

# pull any docker images that might exist for this version
docker pull rcarson/minecraft:${version} || true

manifest="$(curl -fsSL "https://s3.amazonaws.com/Minecraft.Download/versions/${version}/${version}.json")" || { 
    echo "error: Bad version (${version})"; exit 1;
}

#sha1=$(echo $manifest | python -c 'import sys, json; print(json.load(sys.stdin)["downloads"]["server"]["sha1"])')
sha1="$(echo $manifest | jq -r .downloads.server.sha1)"

image_id=$(docker build -q -t rcarson/minecraft:${version} \
	          --build-arg MINECRAFT_VERSION=${version} \
	          --build-arg MINECRAFT_SHA=${sha1} .) || {
    echo "-+ Image rcarson/minecraft:${version} not created"
    exit 1
    }

echo "-+ Image rcarson/minecraft:${version} created ($image_id)"

docker push rcarson/minecraft:${version}

if [[ ${TYPE} == 'release' ]]; then
    docker tag ${image_id} rcarson/minecraft:latest
    docker push rcarson/minecraft:latest
fi

