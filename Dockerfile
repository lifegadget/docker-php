FROM ubuntu:14.04
MAINTAINER LifeGadget <contact-us@lifegadget.co>

# Setup Base Environment
ENV DEBIAN_FRONTEND noninteractive
# apt-get magic
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 6AF0E1940624A220
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C
RUN echo 'APT::Install-Recommends "0"; \n\
		APT::Get::Assume-Yes "true"; \n\
		APT::Get::force-yes "true"; \n\
		APT::Install-Suggests "0";' \
		> /etc/apt/apt.conf.d/01buildconfig \
 	&& echo " \
		deb mirror://mirrors.ubuntu.com/mirrors.txt trusty main restricted universe multiverse \n\
		deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-updates main restricted universe multiverse \n\
		deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-backports main restricted universe multiverse \n\
		deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-security main  restricted universe multiverse \n\
		deb http://ppa.launchpad.net/ondrej/php5/ubuntu trusty main \n\
		deb-src http://ppa.launchpad.net/ondrej/php5/ubuntu trusty main \n" \ 
		> /etc/apt/sources.list \
		&& apt-get update
# Add a nicer bashrc config
ADD https://raw.githubusercontent.com/lifegadget/bashrc/master/snippets/history.sh /etc/bash.history
ADD https://raw.githubusercontent.com/lifegadget/bashrc/master/snippets/color.sh /etc/bash.color
ADD https://raw.githubusercontent.com/lifegadget/bashrc/master/snippets/shortcuts.sh /etc/bash.shortcuts
RUN { \
		echo ""; \
		echo 'source /etc/bash.history'; \
		echo 'source /etc/bash.color'; \
		echo 'source /etc/bash.shortcuts'; \
	} >> /etc/bash.bashrc

# Install PHP and related modules
RUN apt-get install -y \
	php5 \
	php5-mcrypt \
	php5-fpm \
	vim \
	wget
	
# Install Couchbase C-library and PECL extension
RUN wget -O/etc/apt/sources.list.d/couchbase.list http://packages.couchbase.com/ubuntu/couchbase-ubuntu1404.list \
		&& wget -O- http://packages.couchbase.com/ubuntu/couchbase.key | sudo apt-key add - \
		&& apt-get update \
		&& apt-get install -y --no-install-recommends pkg-config libcouchbase2-libevent libcouchbase-dev libmemcached-dev php-pear php5-dev make \
		&& pecl config-set php_ini /app/conf/php.ini \
		&& pecl install couchbase-1.2.2 \
		&& pecl install memcached --alldeps \
		&& { \
			echo "; Couchbase PHP SDK"; \
			echo "extension=/usr/lib/php5/20121212/couchbase.so"; \
			echo "couchbase.serializer = php"; \
			echo "couchbase.compressor = none"; \
			echo "couchbase.compression_factor = 1.3"; \
			echo "couchbase.compression_threshold = 2000"; \
			echo "couchbase.restflush = On"; \
			echo "; Experimental performance optimizer"; \
			echo "couchbase.config_cache = \"/app/cache/couchbase\""; \
		} > /etc/php5/fpm/conf.d/30-couchbase.ini \
		&& cp /etc/php5/fpm/conf.d/30-couchbase.ini /etc/php5/cli/conf.d \
		&& { \
			echo "; Memcached PHP SDK"; \
			echo "extension=/usr/lib/php5/20121212/memcached.so"; \
		} > /etc/php5/fpm/conf.d/30-memcached.ini \
		&& cp /etc/php5/fpm/conf.d/30-memcached.ini /etc/php5/cli/conf.d
# TODO: add some cleanup after couchbase built

# Setup App Directory structure
RUN mkdir -p /app \
	&& mkdir -p /app/content \
	&& mkdir -p /app/content/fpm \
	&& mkdir -p /app/logs \
	&& mkdir -p /app/sockets \
	&& mkdir -p /app/conf \
	&& mkdir -p /app/conf.d \
	&& mkdir -p /app/resources \
	&& mkdir -p /app/cache \
	&& mkdir -p /app/cache/couchbase
	
# Baseline config
COPY resources/php-fpm.conf /app/conf/php-fpm.conf 
COPY resources/php.ini /app/conf/php.ini
COPY resources/default.conf /app/conf.d/default.conf
# Create some basic content pages for testing purposes
RUN echo "<?php phpinfo(); ?>" > /app/content/fpm/index.php \
	&& echo "<pre><?php var_export(\$_SERVER); ?></pre>" > /app/content/fpm/server.php \
	&& chown -R www-data:www-data /app 
# Move original config files out of the way, create symlink to new source (for commands like "service php5-fpm reload", etc.)
RUN mv /etc/php5/fpm/php-fpm.conf /etc/php5/fpm/php-fpm.conf.template \
	&& mv /etc/php5/fpm/php.ini /etc/php5/fpm/php.ini.template \
	&& ln -s /app/conf/php.ini  /etc/php5/fpm/php.ini \
	&& ln -s /app/conf/php-fpm.conf  /etc/php5/fpm/php-fpm.conf 
		
# Volume Shares
VOLUME ["/app/content"]
VOLUME ["/app/sockets"]
VOLUME ["/app/conf"]
VOLUME ["/app/conf.d"]
VOLUME ["/app/logs"]

# Add resources
ADD resources/php.txt /app/resources/php.txt
ADD resources/docker.txt /app/resources/docker.txt
ADD resources/docker-php /app/resources/docker-php 
RUN chmod +x /app/resources/docker-php \
	&& ln -s /app/resources/docker-php /usr/local/bin/docker-php

ENV DEBIAN_FRONTEND newt
WORKDIR /app 
# ENTRYPOINT ["php5-fpm"]
ENTRYPOINT ["docker-php"]

