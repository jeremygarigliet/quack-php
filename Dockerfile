FROM alpine:3.10

LABEL maintainer="Jeremy Garigliet <jeremy.garigliet@gmail.com>"

# Set timezone
RUN apk add --no-cache tzdata && \
    cp /usr/share/zoneinfo/Europe/Paris /etc/localtime && \
    echo "Europe/Paris" > /etc/timezone && \
    apk del tzdata && \
    date

RUN apk add --no-cache \
      composer \
      php7-tokenizer \
      php7-dom \
      php7-phar \
      php-bz2 \
      php7-simplexml \
      php7-ctype \
      php7-xmlwriter

RUN sed -i 's/memory_limit = 128M/memory_limit = 1024M/' /etc/php7/php.ini

ENV PATH=$PATH:/root/.composer/vendor/bin

RUN mkdir /project /report

RUN composer global require phpmetrics/phpmetrics

RUN composer global require --dev phpstan/phpstan && \
    phpstan -V

RUN wget -qc https://phpmd.org/static/latest/phpmd.phar && \
    mv phpmd.phar /usr/local/bin/phpmd && \
    chmod +x /usr/local/bin/phpmd && \
    phpmd --version

RUN wget -qc https://squizlabs.github.io/PHP_CodeSniffer/phpcs.phar && \
    chmod +x phpcs.phar && \
    mv phpcs.phar /usr/local/bin/phpcs && \
    phpcs --version

RUN wget -qc https://phar.phpunit.de/phpcpd.phar && \
    chmod +x phpcpd.phar && \
    mv phpcpd.phar /usr/local/bin/phpcpd && \
    phpcpd --version

RUN wget -qc https://phar.phpunit.de/phploc.phar && \
    chmod +x phploc.phar && \
    mv phploc.phar /usr/local/bin/phploc && \
    phploc --version

COPY run.sh /usr/local/bin/quack

RUN chmod +x /usr/local/bin/quack

WORKDIR /project

ENTRYPOINT [ "quack" ]