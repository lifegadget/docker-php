FROM ubuntu:14.04
MAINTAINER LifeGadget <contact-us@lifegadget.co>

# Setup Base Environment
ENV DEBIAN_FRONTEND noninteractive
# apt-get magic
RUN echo 'APT::Install-Recommends "0"; \n\
		APT::Get::Assume-Yes "true"; \n\
		APT::Get::force-yes "true"; \n\
		APT::Install-Suggests "0";' \
		> /etc/apt/apt.conf.d/01buildconfig \
 	&& echo " \
		deb mirror://mirrors.ubuntu.com/mirrors.txt trusty main restricted universe multiverse \n\
		deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-updates main restricted universe multiverse \n\
		deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-backports main restricted universe multiverse \n\
		deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-security main restricted universe multiverse\n\
		deb http://ppa.launchpad.net/ondrej/php5/ubuntu trusty main\n\
		deb-src http://ppa.launchpad.net/ondrej/php5/ubuntu trusty main" 
		> /etc/apt/sources.list
RUN apt-get update

# Install PHP
RUN apt-get install -y \
	php5 \
	php5-cli
# Install PHP modules
RUN apt-get install -y \
	php5-mcrypt \
	php5-fpm 

# App Directory / Subdirectories
RUN mkdir -p /app
# The default directory for content
# if multiple services/apps being pooled then 
# using a subdirectory per service is probably a good idea
RUN mkdir -p /app/content
RUN mkdir -p /app/resources
# to start, however, we'll just add a single index.php file
# at the root that displays the phpinfo
RUN echo "<?php phpinfo(); ?>" > /app/index.php
RUN chown -R www-data:www-data /app

# Install Node and dependencies for bootstrapper
RUN apt-get install -y nodejs build-essential nodejs-legacy npm
WORKDIR /app
RUN cd /app && export USER=root; npm install commander chalk exec-sync
ADD https://raw.githubusercontent.com/lifegadget/docker-php/master/resources/bootstrapper.js /app
# Include ascii logos
ADD https://raw.githubusercontent.com/lifegadget/docker-php/master/resources/docker.txt /app/resources
ADD https://raw.githubusercontent.com/lifegadget/docker-php/master/resources/php.txt /app/resources

# Baseline PHP-FPM Configuration
RUN rm /etc/php5/fpm/php-fpm.conf
ADD https://raw.githubusercontent.com/lifegadget/docker-php/master/resources/php-conf-global.ini /etc/php5/fpm/php-fpm.conf

# Branch based on 'container managed' or 'host configured'
# (because Dockerfile doesn't support conditional logic we'll go outside it for this)
# ADD https://raw.githubusercontent.com/lifegadget/docker-php/master/resources/pool-setup.sh /tmp/pool-setup.sh
# RUN ['/bin/bash','/tmp/pool-setup.sh']


RUN sed -i '/^listen /c listen = 0.0.0.0:9000' /etc/php5/fpm/pool.d/www.conf

RUN sed -i 's/^listen.allowed_clients/;listen.allowed_clients/' /etc/php5/fpm/pool.d/www.conf

EXPOSE 9000
VOLUME /website
# Reset to default interactivity
ENV DEBIAN_FRONTEND newt

ENTRYPOINT ["bootstrapper.js"]
CMD ["start"]


