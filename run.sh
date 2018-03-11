#!/usr/bin/env bash
#
#
# Robert Carson <robert.carson@gmail.com>

BASEDIR='/srv/minecraft'
VERSION='1.12.2'
PORT='25565'
RCON_PORT='25575'
INTERACTIVE='false'

declare -a ENV_OPTS

while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--interactive) INTERACTIVE='true';;
        -p|--port) PORT="${2}"; shift;;
        -d|--dir) BASEDIR="${2}"; shift;;
        -v|--version) VERSION="${2}"; shift;;
        -s|--seed) ENV_OPTS+=( '--env' "LEVEL_SEED=${2}" ); shift;;
        --difficulty) ENV_OPTS+=( '--env' "DIFFICULTY=${2}" ); shift;;
        --gamemode) ENV_OPTS+=( '--env' "GAMEMODE=${2}" ); shift;;
        --generator-settings) ENV_OPTS+=( '--env' "GENERATOR_SETTINGS=${2}" ); shift;;
        --motd) ENV_OPTS+=( '--env' "MOTD=${2}" ); shift;;
        --rcon) ENV_OPTS+=( '--env' "ENABLE_RCON=true" );;
        --rcon-port) RCON_PORT="${2}"; shift;;
        --rcon-password) ENV_OPTS+=( '--env' "RCON_PASSWORD=${2}" ); shift;;
        *) break;;
    esac
    shift
done

for instance in "$@"; do
    cur_container="$(docker ps -aqf "name=${instance}")"

    if [[ -n ${cur_container:+_} ]]; then
        docker start "${cur_container}"
        exit $?
    fi
    
    if [[ -z "${BASEDIR}" ]]; then
        volume_mount="${instance}"  # this becomes a named volume
    else
        volume_mount="${BASEDIR}/${instance}"
    fi

    DOCKER_RUN_OPTS=( '--name' "${instance}" 
                      '--volume' "${volume_mount}:/var/lib/minecraft"
                      '--publish' "${PORT}:25565"
                      '--publish' "${RCON_PORT}:25575" )

    if $INTERACTIVE; then
        docker run -it --rm "${ENV_OPTS[@]}" "${DOCKER_RUN_OPTS[@]}" rcarson/minecraft:${VERSION}
    else
        #echo docker run "${ENV_OPTS[@]}" "${DOCKER_RUN_OPTS[@]}" --detach rcarson/minecraft:${VERSION}
        container="$(docker run "${ENV_OPTS[@]}" "${DOCKER_RUN_OPTS[@]}" --detach rcarson/minecraft:${VERSION})"
        return_val=$?

        if [[ $return_val -ne 0 ]]; then
            docker rm ${container}
            echo "Failed to start minecraft server ($instance). aborting."
            exit $return_val
        fi
        
        echo "Started minecraft server ($instance)."
    fi
done
