ARG PHP_VERSION=8.2
ARG COMPOSER_VERSION=2.2
ARG DEPLOYER_VERSION=v6.8.0
ARG PHPCS_VERSION=v3.65.0

FROM php:${PHP_VERSION}-cli

RUN apt-get update \
   && apt-get install -y \
      git-core \
      pigz unzip zip \
      rsync \
   && docker-php-ext-install pdo_mysql \
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
       && pecl install amqp \
       && docker-php-ext-enable amqp \
       && docker-php-ext-install pcntl \
   && apt-get -y install libgmp-dev \
       && docker-php-ext-install gmp \
   && docker-php-ext-install bcmath \
   && rm -rf /var/lib/apt/lists/*

# PHP Configuration
RUN echo "memory_limit=-1" > $PHP_INI_DIR/conf.d/memory-limit.ini
RUN echo "date.timezone=UTC" > $PHP_INI_DIR/conf.d/date_timezone.ini
    
# Install PHP Code sniffer
RUN curl -OL https://github.com/PHP-CS-Fixer/PHP-CS-Fixer/releases/download/${PHPCS_VERSION}/php-cs-fixer.phar \
    && chmod 755 phpcs.phar \
    && mv phpcs.phar /usr/local/bin/ \
    && ln -s /usr/local/bin/phpcs.phar /usr/local/bin/phpcs
    
# Install deployer
RUN curl -LO https://deployer.org/releases/${DEPLOYER_VERSION}/deployer.phar \
    && mv deployer.phar /usr/local/bin/dep \
    && chmod +x /usr/local/bin/dep

# Install composer
COPY --from=composer:${COMPOSER_VERSION} /usr/bin/composer /usr/local/bin/composer