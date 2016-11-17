FROM   openjdk:8-jdk-alpine
MAINTAINER Robert Carson <robert.carson@gmail.com>

RUN apk --update add curl ca-certificates bash \
 && rm -rf /tmp/* \
 && rm -rf /var/cache/apk/*

ENV JAVA_OPTS "-Xmx2048m"

RUN mkdir -p /var/lib/minecraft \
 && mkdir -p /usr/share/minecraft

ENV MINECRAFT_VERSION 1.11
ENV MINECRAFT_SHA 48820c84cb1ed502cb5b2fe23b8153d5e4fa61c0

ENV MINECRAFT_URL=https://s3.amazonaws.com/Minecraft.Download/versions/${MINECRAFT_VERSION}/minecraft_server.${MINECRAFT_VERSION}.jar

RUN curl -fsSL ${MINECRAFT_URL} -o /usr/share/minecraft/minecraft.jar \
 && echo "${MINECRAFT_SHA}  /usr/share/minecraft/minecraft.jar" | sha1sum -c -
 
COPY ./minecraft-entrypoint.sh /usr/local/bin/minecraft-entrypoint.sh

VOLUME /var/lib/minecraft

WORKDIR /var/lib/minecraft

EXPOSE 25565

ENTRYPOINT ["minecraft-entrypoint.sh"]

