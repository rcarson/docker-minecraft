FROM openjdk:8-jdk-alpine
MAINTAINER Robert Carson <robert.carson@gmail.com>

RUN apk --update add gettext curl ca-certificates bash \
 && rm -rf /tmp/* \
 && rm -rf /var/cache/apk/*


RUN mkdir -p /var/lib/minecraft \
 && mkdir -p /usr/share/minecraft/ref

COPY server.properties /usr/share/minecraft/ref/server.properties.tmpl
COPY minecraft-support /usr/local/bin/
COPY minecraft.sh /usr/local/bin/

VOLUME /var/lib/minecraft
WORKDIR /var/lib/minecraft

EXPOSE 25565
EXPOSE 25575

ENTRYPOINT ["minecraft.sh"]

ENV JAVA_OPTS "-Xmx2048m"

#ARG MINECRAFT_URL=https://s3.amazonaws.com/Minecraft.Download/versions/${MINECRAFT_VERSION}/minecraft_server.${MINECRAFT_VERSION}.jar
ARG MINECRAFT_URL=https://launcher.mojang.com/v1/objects/808be3869e2ca6b62378f9f4b33c946621620019/server.jar

ARG MINECRAFT_VERSION=1.14.4
ENV MINECRAFT_VERSION ${MINECRAFT_VERSION}

RUN curl -fsSL ${MINECRAFT_URL} -o /usr/share/minecraft/server.jar 

