#!/usr/bin/env bash
#
#

set -eu

function usage {
    echo "Usage: $(basename $0) [OPTION]..."
    echo "Build the minecraft docker image"
    echo ""
    echo "  -h, --help               This message."
    echo "  --snapshot               The release type to build (snapshot, default: release)"
    echo "  --version                The version to build"
    echo ""

}

declare CURL_OPTS \
        TYPE \
        VERSION \
        VERSIONS_MANIFEST_URL \
        VERSIONS_MANIFEST_JSON \
        VERSION_MANIFEST_URL \
        MINECRAFT_VERSION \
        MINECRAFT_SHA1 \
        MINECRAFT_URL \
        DOCKER_BUILD_OPTS \
        IMAGE_ID

CURL_OPTS=( '-f' '-s' '-S' '-L' )
TYPE='release'

while [[ $# -gt 0 ]]; do
    case $1 in
	    -h|--help) usage; exit 1;;
        --snapshot) TYPE='snapshot';;
	    --version) MINECRAFT_VERSION="$2"; shift;;
    esac
    shift
done

VERSIONS_MANIFEST_URL='https://launchermeta.mojang.com/mc/game/version_manifest.json'
VERSIONS_MANIFEST_JSON="$(curl "${CURL_OPTS[@]}" "${VERSIONS_MANIFEST_URL}")"

if [[ ! -n "${MINECRAFT_VERSION:+_}" ]]; then
    # get latest release version
    MINECRAFT_VERSION="$(echo "${VERSIONS_MANIFEST_JSON}" | jq -r ".latest.${TYPE}")"
fi

echo "-+ Build Version: $MINECRAFT_VERSION ($TYPE)"

# pull any docker images that might exist for this version
docker pull rcarson/minecraft:${MINECRAFT_VERSION} || true

MANIFEST_URL="https://s3.amazonaws.com/Minecraft.Download/versions/${MINECRAFT_VERSION}/${MINECRAFT_VERSION}.json"

VERSION_MANIFEST_URL="$(echo "${VERSIONS_MANIFEST_JSON}" | jq -r --arg latest_version "${MINECRAFT_VERSION}" '.versions[] | select(.id == $latest_version) | .url')"
VERSION_MANIFEST_JSON="$(curl "${CURL_OPTS[@]}" "${VERSION_MANIFEST_URL}")"

MINECRAFT_SHA="$(echo "${VERSION_MANIFEST_JSON}" | jq -r '.downloads.server.sha1')"
MINECRAFT_URL="$(echo "${VERSION_MANIFEST_JSON}" | jq -r '.downloads.server.url')"

set -x

DOCKER_BUILD_OPTS=(
              '-q'
	          '--build-arg' "MINECRAFT_VERSION=${MINECRAFT_VERSION}"
	          '--build-arg' "MINECRAFT_SHA=${MINECRAFT_SHA}"
	          '--build-arg' "MINECRAFT_URL=${MINECRAFT_URL}"
              '-t' "rcarson/minecraft:${MINECRAFT_VERSION}"
              )

IMAGE_ID="$(docker build "${DOCKER_BUILD_OPTS[@]}" -f Dockerfile .)" || {
    echo "-+ Image rcarson/minecraft:${MINECRAFT_VERSION} not created"
    exit 1
}

echo "-+ Image rcarson/minecraft:${MINECRAFT_VERSION} created ($IMAGE_ID)"

docker push rcarson/minecraft:${MINECRAFT_VERSION}

if [[ ${TYPE} == 'release' ]]; then
    docker tag ${IMAGE_ID} rcarson/minecraft:latest
    docker push rcarson/minecraft:latest
fi

