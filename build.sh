#!/usr/bin/env bash
#
#

set -e

function usage {
    echo "Usage: $(basename $0) [OPTION]..."
    echo "Build the minecraft docker image"
    echo ""
    echo "  -h, --help               This message."
    echo "  -t, --type RELEASE_TYPE  The release type to build (snapshot, release*)"
    echo ""

}

TYPE='release'

while [[ $# -gt 0 ]]; do
    case $1 in
	-h|--help) usage; exit 1;;
        -t|--type) TYPE=${2}; shift;;
    esac
    shift
done

# get latest release version
version=$(curl -fsSL https://launchermeta.mojang.com/mc/game/version_manifest.json \
	| python -c "import sys, json; print(json.load(sys.stdin)[\"latest\"][\"$TYPE\"])")

echo "Build Version: $version ($TYPE)"

manifest="$(curl -fsSL "https://s3.amazonaws.com/Minecraft.Download/versions/${version}/${version}.json")"

sha1=$(echo $manifest | python -c 'import sys, json; print(json.load(sys.stdin)["downloads"]["server"]["sha1"])')

docker build -t rcarson/minecraft:${version} \
	     --build-arg MINECRAFT_VERSION=${version} \
	     --build-arg MINECRAFT_SHA=${sha1} .
docker push rcarson/minecraft:${version}

if [[ ${TYPE} == 'release' ]]; then
    docker tag rcarson/minecraft:${version} rcarson/minecraft:latest
    docker push rcarson/minecraft:latest
fi

