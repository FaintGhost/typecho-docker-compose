FROM php:7.3.11-fpm-alpine

ENV TZ=Europe/Berlin

RUN apk update \
	&& apk add tzdata \
	&& echo "${TZ}" > /etc/timezone \
	&& ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime \
	\
	&& docker-php-ext-install -j$(nproc) pdo_mysql \
	\
	&& apk add \
		freetype \
		freetype-dev \
		libpng \
		libpng-dev \
		libjpeg-turbo \
		libjpeg-turbo-dev \
	&& docker-php-ext-configure gd \
		--with-freetype-dir=/usr/include/ \
		--with-jpeg-dir=/usr/include/ \
	&& docker-php-ext-install -j$(nproc) gd \
	&& apk del \
		freetype-dev \
		libpng-dev \
		libjpeg-turbo-dev \
	\
	&& rm /var/cache/apk/*

COPY ./php.ini /usr/local/etc/php/
COPY ./www.conf /usr/local/etc/php-fpm.d/
