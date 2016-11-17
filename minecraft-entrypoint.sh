#!/bin/sh
#
#

set -e

if [ "$#" -eq 0 -o "${1#-}" != "$1" ]; then
    set -- java ${JAVA_OPTS} ${@} -jar /usr/share/minecraft/minecraft.jar
fi

exec "$@"
