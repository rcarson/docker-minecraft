#!/bin/bash
#
#

set -ex

declare -a JAVA_OPTS_ARRAY

# auto accept the EULA
echo "eula=TRUE" > /var/lib/minecraft/eula.txt

# copy any reference files to /var/lib/minecraft
# shellcheck disable=SC2016
find /usr/share/minecraft/ref/ \
    -type f \
    -exec /bin/bash -c 'source /usr/local/bin/minecraft-support; for arg; do copy_reference_file "$arg"; done' _ {} +

# Load all the java options into an array
while IFS= read -d '' -r opt; do
    JAVA_OPTS_ARRAY+=( "${opt}" )
done < <([[ $JAVA_OPTS ]] && xargs printf '%s\0' <<<"$JAVA_OPTS")

if [[ "$#" -eq 0 || "${1#-}" != "$1" ]]; then
    set -- java "${JAVA_OPTS_ARRAY[@]}" "${@}" \
                -jar /usr/share/minecraft/minecraft.jar nogui
fi

exec "$@"
