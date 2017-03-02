FROM lsiobase/xenial
MAINTAINER zaggash <zaggash@users.noreply.github.com>, sparklyballs, ajw107 (Alex Wood)

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"

# package versions
ARG MONGO_VERSION="3.4.2"

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ARG COPIED_APP_PATH="/tmp/git-app"
ARG BUNDLE_DIR="/tmp/bundle-dir"

#make life easy for yourself
ENV TERM=xterm-color

# install packages
RUN \
 apt-get update && \
 apt-get install -y \
	curl \
	nano && \
 curl -sL \
	https://deb.nodesource.com/setup_0.10 | bash - && \
 apt-get install -y \
	--no-install-recommends \
	nodejs=0.10.48-1nodesource1~xenial1 && \
 npm install -g npm@latest && \

# install mongo
 curl -o \
 /tmp/mongo.tgz -L \
	https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-ubuntu1604-$MONGO_VERSION.tgz  && \
 mkdir -p \
	/tmp/mongo_app && \
 tar xf \
 /tmp/mongo.tgz -C \
	/tmp/mongo_app --strip-components=1 && \
 mv /tmp/mongo_app/bin/mongod /usr/bin/ 
 #&& \

# install plexrequests
#god I hate nested quotes
RUN plexreq_tarball_url='$(curl -sX GET '\''https://api.github.com/repos/lokenx/plexrequests-meteor/releases/latest'\'' | awk '\''/tarball_url/{print $4;exit}'\'' FS='\''[""]'\'')'
	#&& \
RUN echo "plexreq_tarball_url: [${plexreq_tarball_url}]"
 RUN curl -o \
 /tmp/source.tar.gz -L "${plexreq_tarball_url}"
#	"https://github.com/lokenx/plexrequests-meteor/archive/${plexreq_tag}.tar.gz" 
	#&& \
 RUN mkdir -p \
	$COPIED_APP_PATH 
	#&& \
 RUN tar xvf \
 /tmp/source.tar.gz -C \
	"$COPIED_APP_PATH" --strip-components=1 
	#&& \
RUN cd $COPIED_APP_PATH 
 #&& \
 RUN HOME=/tmp \
 curl -sL \
	https://install.meteor.com | \
	sed s/--progress-bar/-sL/g | /bin/sh 
	#&& \
RUN HOME=/tmp \
 meteor build \
	--directory $BUNDLE_DIR \
	--server=http://localhost:3000 
	#&& \
 RUN cd $BUNDLE_DIR/bundle/programs/server/ 
 #&& \
 RUN npm i 
 #&& \
 RUN mv $BUNDLE_DIR/bundle /app 
 
 #&& \

# cleanup
RUN npm cache clear > /dev/null 2>&1 && \
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
