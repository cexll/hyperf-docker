# base
FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

# mirror
RUN  sed -i "s@http://.*archive.ubuntu.com@http://repo.huaweicloud.com@g" /etc/apt/sources.list \
    && sed -i "s@http://.*security.ubuntu.com@http://repo.huaweicloud.com@g" /etc/apt/sources.list


RUN set -ex \
    && apt-get update \
    && apt-get install -y tzdata curl wget \
    && ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata \
    && apt-get install -y php7.4 \
    php7.4-bcmath \
    php7.4-curl \
    php7.4-dom \
    php7.4-gd \
    php7.4-mbstring \
    php7.4-mysql \
    php7.4-redis \
    php7.4-zip \
    php7.4-dev \
    php7.4-opcache \
    php7.4-cli \
    php7.4-bz2




# cli
ARG SWOOLE_VERSION

##
# ---------- env settings ----------
##
ENV SWOOLE_VERSION=${SWOOLE_VERSION:-"4.5.2"} \
    #  install and remove building packages
    PHPIZE_DEPS="autoconf dpkg-dev dpkg file g++ gcc libc-dev make php7.4-dev pkgconf re2c libtool automake libaio-dev"

ENV HUAWEICLOUD_MIDDOR=""

# update
RUN set -ex \
    && apt-get update \
    && apt-get install -y git \
    && apt-get install -y $PHPIZE_DEPS \
    # download
    && cd /tmp \
    && curl -SL "https://github.com/swoole/swoole-src/archive/v${SWOOLE_VERSION}.tar.gz" -o swoole.tar.gz \
    && ls -alh \
    # php extension:swoole
    && cd /tmp \
    && mkdir -p swoole \
    && tar -xf swoole.tar.gz -C swoole --strip-components=1 \
    && ( \
        cd swoole \
        && phpize \
        && ./configure --enable-mysqlnd --enable-openssl --enable-http2 \
        && make -s -j$(nproc) && make install \
    ) \
    && echo "memory_limit=1G" > /etc/php/7.4/cli/conf.d/00-default.ini \
    && echo "extension=swoole.so" > /etc/php/7.4/cli/conf.d/50-swoole.ini \
    && echo "swoole.use_shortname = 'Off'" >> /etc/php/7.4/cli/conf.d/50-swoole.ini \
    # clear
    && php -v \
    && php -m \
    && php --ri swoole \
    && echo -e "\033[42;37m Build Completed :).\033[0m\n"


