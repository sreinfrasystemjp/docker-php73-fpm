################################
FROM gunosy/neologd-for-mecab:2019.05.24 as neologd
LABEL maintainer="https://sre-infra-system.jp/"

################################
FROM php:7.3.5-fpm-stretch
LABEL maintainer="https://sre-infra-system.jp/"

ENV DEBIAN_FRONTEND noninteractive
ENV PECL_MSGPACK_VERSION 2.0.3
ENV PECL_IGBINARY_VERSION 3.0.1
ENV PECL_MEMCACHED_VERSION 3.1.3
ENV PECL_REDIS_VERSION 4.3.0
ENV PECL_MECAB_VERSION 0.6.0
ENV PECL_GMAGICK_VERSION 2.0.5RC1
ENV COMPOSER_VERSION 1.8.5
ENV GO_CRON_VERSION 0.0.7


# apt
RUN apt-get update -qq && \
    apt-get install -qq -y --no-install-recommends --no-install-suggests \
      fonts-noto-cjk       \
      git                  \
      graphicsmagick       \
      less                 \
      locales              \
      mariadb-client       \
      mecab                \
      logrotate            \
      net-tools            \
      procps               \
      python               \
      python-pip           \
      redis-tools          \
      vim                  \
      wget                 \
      unzip                \
      libzip-dev           \
      libmemcached-dev     \
      liblz4-dev           \
      libmecab-dev         \
      libgraphicsmagick1-dev \
      && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# locale
RUN sed -i "s/# ja_JP.UTF-8 UTF-8/ja_JP.UTF-8 UTF-8/" /etc/locale.gen && \
    locale-gen

# user
RUN groupadd -g 1000 app && \
    useradd -m -d /var/www/app -s /bin/bash -u 1000 -g 1000 app

# php
RUN docker-php-ext-install \
      exif \
      mbstring \
      opcache \
      pdo_mysql \
      zip \
    && \
    pecl install msgpack-${PECL_MSGPACK_VERSION} && \
    pecl install igbinary-${PECL_IGBINARY_VERSION} && \
    pecl install gmagick-${PECL_GMAGICK_VERSION} && \
    docker-php-ext-enable \
      msgpack \
      igbinary \
      gmagick \
    && \
    :

# php-memcached
RUN pecl install --nobuild memcached-${PECL_MEMCACHED_VERSION} && \
    cd "$(pecl config-get temp_dir)/memcached" && \
    phpize && \
    ./configure \
      --with-libmemcached-dir=/usr \
      --with-zlib-dir=/usr \
      --without-system-fastlz \
      --enable-memcached-igbinary \
      --enable-memcached-json \
      --enable-memcached-msgpack \
      --enable-memcached-sasl \
      --disable-memcached-protocol \
      --enable-memcached-session \
    && \
    make && \
    make install && \
    cd .. && \
    rm -rf memcached && \
    docker-php-ext-enable memcached

# php-redis
RUN pecl install --nobuild redis-${PECL_REDIS_VERSION} && \
    cd "$(pecl config-get temp_dir)/redis" && \
    phpize && \
    ./configure \
      --enable-redis-igbinary \
      --enable-redis-lzf \
    && \
    make && \
    make install && \
    cd .. && \
    rm -rf redis && \
    docker-php-ext-enable redis

# php-mecab
RUN cd "$(pecl config-get temp_dir)" && \
    wget -q -O php-mecab-${PECL_MECAB_VERSION}.tar.gz https://github.com/rsky/php-mecab/archive/v${PECL_MECAB_VERSION}.tar.gz && \
    tar xzf php-mecab-${PECL_MECAB_VERSION}.tar.gz && \
    rm -f php-mecab-${PECL_MECAB_VERSION}.tar.gz && \
    cd php-mecab-${PECL_MECAB_VERSION}/mecab && \
    phpize && \
    ./configure --with-mecab=/usr/bin/mecab-config && \
    make && \
    make install && \
    cd ../.. && \
    rm -rf php-mecab-${PECL_MECAB_VERSION} && \
    docker-php-ext-enable mecab && \
    echo "mecab.default_dicdir=/var/lib/mecab/dic/debian" >> /usr/local/etc/php/conf.d/docker-php-ext-mecab.ini

# php.ini
RUN cd /usr/local/etc/php && \
    mkdir conf.d.docker && \
    touch conf.d.docker/php.ini && \
    ln -s conf.d.docker/php.ini

# composer
RUN cd /usr/local/bin && \
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php -r "if (hash_file('sha384', 'composer-setup.php') === '48e3236262b34d30969dca3c37281b3b4bbe3221bda826ac6a9a62d6444cdb0dcd0615698a5cbe587c3f0fe57a54d8f5') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
    php composer-setup.php --filename composer --version=${COMPOSER_VERSION} && \
    php -r "unlink('composer-setup.php');"
USER app
RUN composer config -g repos.packagist composer https://packagist.jp && \
    composer global require hirak/prestissimo
USER root

# supervisord
RUN pip install supervisor==4.0.3 setuptools && \
    mkdir -p /etc/supervisord/conf.d && \
    mkdir -p /var/log/supervisord && \
    mkdir -p /var/run/supervisord && \
    echo_supervisord_conf > /etc/supervisord/supervisord.conf.default

# go-cron
COPY go-cron /usr/local/bin/go-cron

# go-redis-setlock
COPY go-redis-setlock /usr/local/bin/go-redis-setlock

# neologd
COPY --from=neologd /usr/lib/mecab/dic/neologd /var/lib/mecab/dic/neologd
RUN update-alternatives --install /var/lib/mecab/dic/debian mecab-dictionary /var/lib/mecab/dic/neologd 20 && \
    update-alternatives --set mecab-dictionary /var/lib/mecab/dic/neologd

