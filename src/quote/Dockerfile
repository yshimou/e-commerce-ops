FROM composer:2.7 AS vendor

WORKDIR /tmp/
COPY ./composer.json .

RUN composer install \
    --ignore-platform-reqs \
    --no-interaction \
    --no-plugins \
    --no-scripts \
    --no-dev \
    --prefer-dist
#-----------------------------------------------------------------------------

FROM php:8.3-cli AS runtime

WORKDIR /var/www
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN chmod +x /usr/local/bin/install-php-extensions && install-php-extensions opcache pcntl protobuf opentelemetry

COPY --from=vendor /tmp/vendor/ ./vendor/
COPY . .

USER www-data
EXPOSE ${QUOTE_PORT}

ENTRYPOINT ["php", "public/index.php"]
