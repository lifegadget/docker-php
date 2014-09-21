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
		deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-security main restricted universe multiverse \n\
		deb http://ppa.launchpad.net/ondrej/php5/ubuntu trusty main \n\
		deb-src http://ppa.launchpad.net/ondrej/php5/ubuntu trusty main \n" \ 
		> /etc/apt/sources.list
RUN apt-get update
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

# Install PHP
RUN apt-get install -y \
	php5 
# Install PHP modules
RUN apt-get install -y \
	php5-mcrypt \
	php5-fpm
# Create symlink to FPM to have more standard access to command
# (this appears to happen on Ubuntu but not OSX for instance)
RUN if [ -f /usr/sbin/php5-fpm ]; then \
		ln -s /usr/sbin/php5-fpm /usr/sbin/php-fpm; \
	fi;
	
# Helpful helpers
RUN apt-get install -y vim curl

# Install Node and dependencies for CLI/bootstrapper
RUN apt-get install -y nodejs build-essential nodejs-legacy npm
WORKDIR /app
RUN cd /app && export USER=root; npm install commander chalk rsvp xtend fibers debug
ADD resources/docker-php.js /app/resources/docker-php.js
RUN chmod +x /app/resources/docker-php.js
# Put the bootstrapper into the PATH
RUN ln -s /app/resources/docker-php.js /usr/local/bin/docker-php

# App Directory / Subdirectories
RUN mkdir -p /app
# The default directory for content
# if multiple services/apps being pooled then 
# using a subdirectory per service is probably a good idea
RUN mkdir -p /app/html
VOLUME ["/app/html"]
# logging directory for FPM and PHP errors/info
RUN mkdir -p /app/logs
# template-based resource files
RUN mkdir -p /app/resources
# for Unix sockets
RUN mkdir -p /app/sockets
VOLUME ["/app/sockets"]
# Baseline config
RUN mkdir -p /app/config
ADD resources/php-fpm.conf /app/conf/php-fpm.conf
ADD resources/php.ini /app/conf/php.ini
VOLUME ["/app/conf"]
# Move originals out of the way
RUN mv /etc/php5/fpm/php-fpm.conf /etc/php5/fpm/php-fpm.conf.template
RUN mv /etc/php5/fpm/php.ini /etc/php5/fpm/php.ini.template
# Pool Configurations
RUN mkdir -p /app/pool.d
ADD resources/php-pool-default.conf /app/pool.d/default.conf
VOLUME ["/app/pool.d"]

# create index.php file at the root of content
RUN echo "<?php phpinfo(); ?>" > /app/content/index.php
# set app ownership
RUN chown -R www-data:www-data /app

# Include ascii logos
ADD resources/docker.txt /app/resources/docker.txt
ADD resources/php.txt /app/resources/php.txt

# Add some generic templates for use later when adding services
RUN mkdir -p /etc/php5/fpm/templates
ADD resources/php-pool-generic-header.ini /etc/php5/fpm/templates/php-pool-generic-header.ini
ADD resources/php-pool-generic-config.ini /etc/php5/fpm/templates/php-pool-generic-config.ini

EXPOSE 9000
# Reset to default interactivity
ENV DEBIAN_FRONTEND newt

ENTRYPOINT ["docker-php"]
CMD ["start"]


