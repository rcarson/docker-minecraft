#!/bin/sh
#
#

set -e

if [ "$#" -eq 0 -o "${1#-}" != "$1" ]; then
    echo "eula=TRUE" > /var/lib/minecraft/eula.txt
    set -- java ${JAVA_OPTS} ${@} -jar /usr/share/minecraft/minecraft.jar nogui
fi

exec "$@"
