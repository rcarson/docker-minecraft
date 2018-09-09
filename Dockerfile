FROM openjdk:8-jdk-alpine
MAINTAINER Robert Carson <robert.carson@gmail.com>

RUN apk --update add gettext curl ca-certificates bash \
 && rm -rf /tmp/* \
 && rm -rf /var/cache/apk/*

ENV JAVA_OPTS "-Xmx2048m"

RUN mkdir -p /var/lib/minecraft \
 && mkdir -p /usr/share/minecraft/ref

ARG MINECRAFT_VERSION=1.12.2
ENV MINECRAFT_VERSION ${MINECRAFT_VERSION}

ARG MINECRAFT_SHA=886945bfb2b978778c3a0288fd7fab09d315b25f
ARG MINECRAFT_URL=https://s3.amazonaws.com/Minecraft.Download/versions/${MINECRAFT_VERSION}/minecraft_server.${MINECRAFT_VERSION}.jar

RUN curl -fsSL ${MINECRAFT_URL} -o /usr/share/minecraft/minecraft.jar \
 && echo "${MINECRAFT_SHA}  /usr/share/minecraft/minecraft.jar" | sha1sum -c -

COPY server.properties /usr/share/minecraft/ref/server.properties.tmpl

COPY minecraft-support /usr/local/bin/
COPY minecraft.sh /usr/local/bin/

VOLUME /var/lib/minecraft
WORKDIR /var/lib/minecraft

EXPOSE 25565
EXPOSE 25575

ENTRYPOINT ["minecraft.sh"]

