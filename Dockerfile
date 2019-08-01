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

ARG MINECRAFT_URL=https://launcher.mojang.com/v1/objects/3dc3d84a581f14691199cf6831b71ed1296a9fdf/server.jar
RUN curl -fsSL ${MINECRAFT_URL} -o /usr/share/minecraft/server.jar 

