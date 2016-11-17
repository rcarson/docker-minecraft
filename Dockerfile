FROM   openjdk:8-jdk-alpine
MAINTAINER Robert Carson <robert.carson@gmail.com>

RUN apk --update add curl ca-certificates bash \
 && rm -rf /tmp/* \
 && rm -rf /var/cache/apk/*

ENV JAVA_OPTS "-Xmx2048m"

RUN mkdir -p /usr/share/minecraft

ARG MINECRAFT_VERSION
ENV MINECRAFT_VERSION ${MINECRAFT_VERSION:-1.9.4}

ARG MINECRAFT_SHA
ENV MINECRAFT_SHA ${MINECRAFT_SHA:-edbb7b1758af33d365bf835eb9d13de005b1e274}

ENV MINECRAFT_URL=https://s3.amazonaws.com/Minecraft.Download/versions/${MINECRAFT_VERSION}/minecraft_server.${MINECRAFT_VERSION}.jar

ENV MINECRAFT_HOME /var/lib/minecraft

RUN mkdir -p ${MINECRAFT_HOME}

RUN curl -fsSL ${MINECRAFT_URL} -o /usr/share/minecraft/minecraft.jar \
 && echo "${MINECRAFT_SHA}  /usr/share/minecraft/minecraft.jar" | sha1sum -c -
 
RUN echo "eula=TRUE" > ${MINECRAFT_HOME}/eula.txt

COPY ./minecraft-entrypoint.sh /usr/local/bin/minecraft-entrypoint.sh

VOLUME ${MINECRAFT_HOME}

WORKDIR ${MINECRAFT_HOME}

EXPOSE 25565

ENTRYPOINT ["minecraft-entrypoint.sh"]

