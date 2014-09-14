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

# Baseline PHP-FPM Configuration
RUN rm /etc/php5/fpm/php-fpm.conf
ADD https://raw.githubusercontent.com/lifegadget/docker-php/master/resources/php-conf-global.ini /etc/php5/fpm/php-fpm.conf

# Branch based on 'container managed' or 'host configured'
# (because Dockerfile doesn't support conditional logic we'll go outside it for this)
# ADD https://raw.githubusercontent.com/lifegadget/docker-php/master/resources/pool-setup.sh /tmp/pool-setup.sh
# RUN ['/bin/bash','/tmp/pool-setup.sh']


RUN sed -i '/^listen /c \
listen = 0.0.0.0:9000' /etc/php5/fpm/pool.d/www.conf

RUN sed -i 's/^listen.allowed_clients/;listen.allowed_clients/' /etc/php5/fpm/pool.d/www.conf

RUN mkdir -p /app && \
    echo "<?php phpinfo(); ?>" > /app/index.php && \
    chown -R www-data:www-data /app

EXPOSE 9000
VOLUME /website
# Reset to default interactivity
ENV DEBIAN_FRONTEND newt

# ENTRYPOINT ["php5-fpm"]



