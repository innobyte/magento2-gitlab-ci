FROM php:7.2
MAINTAINER Alin Alexandru <alin.alexandru@innobyte.com>

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
   && apt-get install -y libpng-dev libjpeg-dev \
       && docker-php-ext-configure gd --with-jpeg-dir=/usr/lib \
       && docker-php-ext-install gd \
   && apt-get install -y zlib1g-dev \
       && docker-php-ext-install zip \
   && docker-php-ext-install bcmath \
   && apt-get install -y librabbitmq-dev \
       && docker-php-ext-install sockets \
       && pecl install amqp \
       && docker-php-ext-enable amqp \
   && docker-php-ext-install pcntl \
   && rm -rf /var/lib/apt/lists/*

# PHP Configuration
RUN echo "memory_limit=-1" > $PHP_INI_DIR/conf.d/memory-limit.ini
RUN echo "date.timezone=UTC" > $PHP_INI_DIR/conf.d/date_timezone.ini

# Install composer and put binary into $PATH
RUN curl -OL https://getcomposer.org/download/1.10.20/composer.phar \
    && chmod +x composer.phar \
    && mv composer.phar /usr/local/bin/ \
    && ln -s /usr/local/bin/composer.phar /usr/local/bin/composer

# Install PHP Code sniffer
RUN curl -OL https://github.com/squizlabs/PHP_CodeSniffer/releases/download/3.5.8/phpcs.phar \
    && chmod 755 phpcs.phar \
    && mv phpcs.phar /usr/local/bin/ \
    && ln -s /usr/local/bin/phpcs.phar /usr/local/bin/phpcs \
    && curl -OL https://github.com/squizlabs/PHP_CodeSniffer/releases/download/3.5.8/phpcbf.phar \
    && chmod 755 phpcbf.phar \
    && mv phpcbf.phar /usr/local/bin/ \
    && ln -s /usr/local/bin/phpcbf.phar /usr/local/bin/phpcbf

# Install deployer
RUN curl -LO https://deployer.org/releases/v6.8.0/deployer.phar \
    && mv deployer.phar /usr/local/bin/dep \
    && chmod +x /usr/local/bin/dep
