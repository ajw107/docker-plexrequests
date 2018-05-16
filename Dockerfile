FROM lsiobase/ubuntu:xenial

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL MAINTAINER="zaggash <zaggash@users.noreply.github.com>, sparklyballs, ajw107 (Alex Wood)"

# package versions
ARG MONGO_VERSION="3.4.2"

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ARG COPIED_APP_PATH="/tmp/git-app"
ARG BUNDLE_DIR="/tmp/bundle-dir"

#make life easy for yourself
ENV TERM=xterm-color
ENV METEOR_ALLOW_SUPERUSER=1
ENV METEOR_NO_RELEASE_CHECK=1

RUN \
 echo "**** install packages ****" && \
 apt-get update && \
 apt-get install -y \
	curl \
	nano && \
 echo "***** install nodejs ****" && \
 curl -sL \
	https://deb.nodesource.com/setup_0.10 | bash - && \
 apt-get install -y \
	--no-install-recommends \
	nodejs=0.10.48-1nodesource1~xenial1 && \

 echo "**** install mongo ****" && \
 curl -o \
 /tmp/mongo.tgz -L \
	https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-ubuntu1604-${MONGO_VERSION}.tgz  && \
 mkdir -p \
	/tmp/mongo_app && \
 tar xf \
 /tmp/mongo.tgz -C \
	/tmp/mongo_app --strip-components=1 && \
 mv /tmp/mongo_app/bin/mongod /usr/bin/ && \

echo "**** install plexrequests ****" && \
curl -o \
 /tmp/source.tar.gz -L https://api.github.com/repos/lokenx/plexrequests-meteor/tarball &&\
 mkdir -p \
	${COPIED_APP_PATH} && \
 tar xf \
 /tmp/source.tar.gz --strip-components=1 -C \
	"${COPIED_APP_PATH}" && \
 cd  "${COPIED_APP_PATH}" && \
 HOME=/tmp \
 curl -sL \
	https://install.meteor.com/?release=1.4.1.3 | \
	sed s/--progress-bar/-sL/g | /bin/sh && \
 HOME=/tmp \
 meteor build \
	--directory ${BUNDLE_DIR} \
	--server=http://localhost:3000 && \
cd ${BUNDLE_DIR}/bundle/programs/server/ && \
npm i && \
mv ${BUNDLE_DIR}/bundle /app && \
echo "**** cleanup ****" && \
npm cache clear > /dev/null 2>&1 && \
    apt-get clean && \
    rm -rf \
	/tmp/* \
	/tmp/.??* \
	/usr/local/bin/meteor \
	/usr/share/doc \
	/usr/share/doc-base \
	/root/.meteor \
	/var/lib/apt/lists/* \
	/var/tmp/*

# add local files
COPY root/ /
RUN chmod +x /usr/bin/ll

# ports and volumes
EXPOSE 3000
VOLUME /config
