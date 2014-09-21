FROM debian:jessie
MAINTAINER LifeGadget <contact-us@lifegadget.co>
ENV DEBIAN_FRONTEND noninteractive

# get PHP source
ENV PHP_VERSION 5.5.17
ENV PHP_SOURCE_SITE http://ch1.php.net/
ENV PHP_SOURCE_PREFIX distributions/php-
ENV PHP_SOURCE_POSTFIX .tar.gz
RUN apt-get update \
	&& apt-get install -y wget \
	&& mkdir -p /app \
	&& mkdir -p /app/src \
	&& cd /app/src \
	&& wget $PHP_SOURCE_SITE$PHP_SOURCE_PREFIX$PHP_VERSION$PHP_SOURCE_POSTFIX \
	&& tar -xzvf php-$PHP_VERSION$PHP_SOURCE_POSTFIX \
	&& rm /app/src/php-$PHP_VERSION$PHP_SOURCE_POSTFIX \
	&& cd /app/src/php-$PHP_VERSION

# build dependencies & compilation	
RUN { \
		echo ''; \
		echo '# Adding source reference to build PHP'; \
		echo 'deb-src http://ftp.debian.org/debian jessie main contrib non-free'; \
	} >> /etc/apt/sources.list \
	&& buildDeps=" \
			libfcgi-dev \
			libfcgi0ldbl \
			libjpeg62-dbg \
			libmcrypt-dev \
			libssl-dev \
			libxml2-dev \
			libbz2-dev \
			libcurl4-gnutls-dev \
			libpng-dev \
			libjpeg-dev \
			libfreetype6-dev \
			gcc \
			make \
		"; \
	apt-get install -y --no-install-recommends $buildDeps \
	&& cd /app/src/php-$PHP_VERSION \
	&& ./configure \
		--prefix=/app/php \
		--enable-opcache \
		--enable-fpm \
		--with-fpm-user=www-data \
		--with-fpm-group=www-data \
		--with-zlib-dir \
		--with-freetype-dir \
		--enable-cgi \
		--enable-mbstring \
		--with-libxml-dir=/usr \
		--enable-soap \
		--enable-calendar \
		--with-curl \
		--with-mcrypt \
		--with-zlib \
		--with-gd \
		--disable-rpath \
		--enable-inline-optimization \
		--with-bz2 \
		--with-zlib \
		--enable-sockets \
		--enable-sysvsem \
		--enable-sysvshm \
		--enable-pcntl \
		--enable-mbregex \
		--with-mhash \
		--enable-zip \
		--with-pcre-regex \
		# --with-mysql \
		# --with-pdo-mysql \
		# --with-mysqli \
		--with-jpeg-dir=/usr \
		--with-png-dir=/usr \
		--enable-gd-native-ttf \
		--with-openssl \
		--with-libdir=/lib/x86_64-linux-gnu \
		--with-libxml-dir=/usr \
		--enable-exif \
		# --enable-dba \
		--with-gettext \
		# --enable-shmop \
		# --enable-sysvmsg \
		# --enable-wddx \
		# --with-imap \
		# --with-imap-ssl \
		# --with-kerberos \
		--enable-bcmath \
		--enable-ftp \
		--enable-intl \
		--with-pspell \
RUN cd /app/src/php-$PHP_VERSION && /usr/bin/make \
	&& /usr/bin/make install \
	&& rm -r /app/src \
	&& rm -rf /var/lib/apt/lists/* \
	&& apt-get purge -y --auto-remove $buildDeps \
	&& ln -s /app/php/bin/php /usr/local/bin/php
		
# Add conveniences to Bash shell when working within the container
ADD https://raw.githubusercontent.com/lifegadget/bashrc/master/snippets/history.sh /etc/bash.history
ADD https://raw.githubusercontent.com/lifegadget/bashrc/master/snippets/color.sh /etc/bash.color
ADD https://raw.githubusercontent.com/lifegadget/bashrc/master/snippets/shortcuts.sh /etc/bash.shortcuts
RUN { \
		echo ""; \
		echo 'source /etc/bash.history'; \
		echo 'source /etc/bash.color'; \
		echo 'source /etc/bash.shortcuts'; \
	} >> /etc/bash.bashrc

ENTRYPOINT ["docker-php"]
CMD ["start"]


