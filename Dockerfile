FROM ubuntu:14.04
MAINTAINER LifeGadget <contact-us@lifegadget.co>

# Setup Base Environment
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
RUN echo " \
	source /etc/bash.history \n\
	source /etc/bash.color \n\
	source /etc/bash.shortcuts \n\
	" >> /etc/bash.bashrc

# Install PHP
RUN apt-get install -y \
	php5 
# Install PHP modules
RUN apt-get install -y \
	php5-mcrypt \
	php5-fpm
	
# Helpful helpers
RUN apt-get install -y vim curl

# App Directory / Subdirectories
RUN mkdir -p /php

# Create share for configuration additions
RUN mkdir -p /usr/local/nginx/conf.d \
	&& mkdir -p /php \
	&& ln -s /usr/local/nginx/conf.d /nginx/conf.d
VOLUME ["/php/conf.d"]

# Create share for taking over configuration
VOLUME ["/php/conf"]



# The default directory for content
# if multiple services/apps being pooled then 
# using a subdirectory per service is probably a good idea
RUN mkdir -p /php/content
# add a logging directory (global.conf points files here)
RUN mkdir -p /php/log
# create a subdirectory for resource files
RUN mkdir -p /php/resources
# to start, however, we'll just add a single index.php file
# at the root that displays the phpinfo
RUN echo "<?php phpinfo(); ?>" > /php/content/index.php
RUN chown -R www-data:www-data /php

# Include ascii logos
ADD resources/docker.txt /php/resources/docker.txt
ADD resources/php.txt /php/resources/php.txt

# Baseline PHP-FPM Configuration
RUN rm /etc/php5/fpm/php-fpm.conf
ADD resources/php-fpm.conf /etc/php5/fpm/php-fpm.conf
# Baseline PHP.INI
RUN rm /etc/php5/fpm/php.ini
ADD resources/php.ini /etc/php5/fpm/php.ini

# Add a default pool service for now, this default will be removed automatically when the first 
# service is added
ADD resources/php-pool-default.ini /etc/php5/fpm/pool.d/default.conf
# Add some generic templates for use later when adding services
RUN mkdir -p /etc/php5/fpm/templates
ADD resources/php-pool-generic-header.ini /etc/php5/fpm/templates/php-pool-generic-header.ini
ADD resources/php-pool-generic-config.ini /etc/php5/fpm/templates/php-pool-generic-config.ini
# Remove dummy 


EXPOSE 9000

ENTRYPOINT ["php5-fpm"]
CMD ["start"]


