ARG PHP_VERSION=8.4
FROM php:${PHP_VERSION}-cli as base

# php:7.4 is based on Debian bullseye, which is EOL: its packages moved to archive.debian.org
# (deb.debian.org returns 404 for bullseye-security pool files, so ca-certificates cannot be
# upgraded from there). Only applies to EOL releases; newer PHP images are left untouched.
RUN . /etc/os-release \
   && case "$VERSION_CODENAME" in \
        buster|bullseye) \
          sed -i 's|http://deb.debian.org/debian-security|http://archive.debian.org/debian-security|; s|http://deb.debian.org/debian |http://archive.debian.org/debian |' /etc/apt/sources.list \
          && echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99archive-debian ;; \
      esac

# ca-certificates is upgraded explicitly: the stock bullseye bundle (20210119) lacks newer CA roots
# (e.g. Sectigo Public Server Authentication Root R46/E46), so git/composer/curl fail with
# "unable to get local issuer certificate" against hosts using certificates issued under them.
RUN apt-get update \
   && apt-get install -y \
      ca-certificates \
      git-core \
      pigz unzip zip \
      rsync \
      libssl-dev \
   && docker-php-ext-install pdo_mysql \
   && docker-php-ext-install ftp \
   && apt-get install -y libxml2-dev \
       && docker-php-ext-install soap \
   && apt-get install -y libxslt-dev \
       && docker-php-ext-install xsl \
   && apt-get install -y libicu-dev \
       && docker-php-ext-install intl \
   && apt-get install -y libpng-dev libjpeg-dev libfreetype6-dev \
   && apt-get install -y libpng-dev libjpeg-dev \
       && docker-php-ext-configure gd --with-freetype --with-jpeg \
       && docker-php-ext-install gd \
   && apt-get install -y libzip-dev \
       && docker-php-ext-install zip \
   && apt-get install -y librabbitmq-dev \
       && docker-php-ext-install sockets \
       && if [ "$(php -r 'echo PHP_MAJOR_VERSION;')" -lt 8 ]; then pecl install amqp-1.11.0; else pecl install amqp; fi \
       && docker-php-ext-enable amqp \
       && pecl install apcu \
       && docker-php-ext-enable apcu \
       && pecl install pcov \
       && docker-php-ext-enable pcov \
       && pecl install redis \
       && docker-php-ext-enable redis \
       && docker-php-ext-install pcntl \
   && apt-get -y install libgmp-dev \
       && docker-php-ext-install gmp \
   && docker-php-ext-install bcmath \
   && rm -rf /var/lib/apt/lists/*

FROM base as dependencies
ARG COMPOSER_VERSION=latest-2.2.x
ARG DEPLOYER_VERSION=v7.5.12
ARG PHPCS_VERSION=3.7.2
ARG NODE_VERSION=22

# PHP Configuration
RUN echo "memory_limit=-1" > $PHP_INI_DIR/conf.d/memory-limit.ini
RUN echo "date.timezone=UTC" > $PHP_INI_DIR/conf.d/date_timezone.ini
RUN echo "apc.enable_cli=1" > $PHP_INI_DIR/conf.d/apcu-cli.ini

# Install Node.js (includes npm)
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install PHP Code sniffer
RUN curl -OL https://github.com/squizlabs/PHP_CodeSniffer/releases/download/${PHPCS_VERSION}/phpcs.phar \
    && chmod 755 phpcs.phar \
    && mv phpcs.phar /usr/local/bin/ \
    && ln -s /usr/local/bin/phpcs.phar /usr/local/bin/phpcs

# Install deployer
RUN curl -LO https://deployer.org/releases/${DEPLOYER_VERSION}/deployer.phar \
    && mv deployer.phar /usr/local/bin/dep \
    && chmod +x /usr/local/bin/dep

# Install composer
RUN curl -LO https://getcomposer.org/download/${COMPOSER_VERSION}/composer.phar \
    && mv composer.phar /usr/local/bin/composer \
    && chmod +x /usr/local/bin/composer
