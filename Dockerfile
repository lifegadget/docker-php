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
RUN echo " \
	source /etc/bash.history \n\
	source /etc/bash.color \n\
	source /etc/bash.shortcuts \n\
	" >> /etc/bash.bashrc

# Install PHP
RUN apt-get install -y \
	php5 \
	php5-cli
# Install PHP modules
RUN apt-get install -y \
	php5-mcrypt \
	php5-fpm 

# Install Node and dependencies for bootstrapper
RUN apt-get install -y nodejs build-essential nodejs-legacy npm
WORKDIR /app
RUN cd /app && export USER=root; npm install commander chalk exec-sync
ADD https://raw.githubusercontent.com/lifegadget/docker-php/master/resources/docker-php.js /app/docker-php.js
RUN chmod +x /app/docker-php.js

# App Directory / Subdirectories
RUN mkdir -p /app
# The default directory for content
# if multiple services/apps being pooled then 
# using a subdirectory per service is probably a good idea
RUN mkdir -p /app/content
# make a symbolic link with a friendlier name for host's run command
RUN ln -s /app/content /app_root
VOLUME /app_root
RUN mkdir -p /app/resources
# to start, however, we'll just add a single index.php file
# at the root that displays the phpinfo
RUN echo "<?php phpinfo(); ?>" > /app/index.php
RUN chown -R www-data:www-data /app

# Include ascii logos
ADD https://raw.githubusercontent.com/lifegadget/docker-php/master/resources/docker.txt /app/resources/docker.txt
ADD https://raw.githubusercontent.com/lifegadget/docker-php/master/resources/php.txt /app/resources/php.txt

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
# Reset to default interactivity
ENV DEBIAN_FRONTEND newt

ENTRYPOINT ["/app/docker-php.js"]
CMD ["start"]

# ENTRYPOINT ["/bin/bash"]


