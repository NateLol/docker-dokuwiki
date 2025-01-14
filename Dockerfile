FROM ghcr.io/linuxserver/baseimage-alpine-nginx:3.15

# set version label
ARG BUILD_DATE
ARG VERSION
ARG DOKUWIKI_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="chbmb"

RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache --virtual=build-dependencies \
    tar \
    xmlstarlet && \
  echo "**** install runtime packages ****" && \
  apk add --no-cache \
    curl \
    imagemagick \
    php8-bz2 \
    php8-ctype \
    php8-curl \
    php8-dom \
    php8-gd \
    php8-iconv \
    php8-ldap \
    php8-pdo_mysql \
    php8-pdo_pgsql \
    php8-pdo_sqlite \
    php8-pecl-imagick \
    php8-sqlite3 \
    php8-xml \
    php8-zip && \
  echo "**** install dokuwiki ****" && \
  if [ -z ${DOKUWIKI_RELEASE+x} ]; then \
    DOKUWIKI_RELEASE=$(wget https://download.dokuwiki.org/rss -O - 2>/dev/null | \
        xmlstarlet sel -T -t -v '/rss/channel/item[1]/link' | \
        cut -d'-' -f2-4 | cut -d'.' -f1 ); \
  fi && \
  curl -o \
  /tmp/dokuwiki.tar.gz -L \
    "https://github.com/splitbrain/dokuwiki/archive/release_stable_${DOKUWIKI_RELEASE}.tar.gz" && \
  mkdir -p \
    /app/www/public && \
  tar xf \
    /tmp/dokuwiki.tar.gz -C \
    /app/www/public --strip-components=1 && \
  echo "**** cleanup ****" && \
  apk del --purge \
    build-dependencies && \
  rm -rf \
    /root/.cache \
    /tmp/*

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 80 443
VOLUME /config
