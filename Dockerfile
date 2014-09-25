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
	php5-fpm
# Helpful helpers
RUN apt-get install -y vim curl

# Setup App Directory structure
RUN mkdir -p /app \
	&& mkdir -p /app/html \
	&& mkdir -p /app/logs \
	&& mkdir -p /app/sockets \
	&& mkdir -p /app/conf \
	&& mkdir -p /app/conf.d \
	&& mkdir -p /app/resources
	
# Baseline config
ADD resources/php-fpm.conf /app/conf/php-fpm.conf 
ADD resources/php.ini /app/conf/php.ini
ADD resources/php-pool-default.conf /app/conf.d/default.conf
RUN echo "<?php phpinfo(); ?>" > /app/html/index.php \
	&& chown -R www-data:www-data /app
# Move originals out of the way, create symlink to new source (for commands like "service php5-fpm reload", etc.)
RUN mv /etc/php5/fpm/php-fpm.conf /etc/php5/fpm/php-fpm.conf.template \
	&& mv /etc/php5/fpm/php.ini /etc/php5/fpm/php.ini.template \
	&& ln -s /app/conf/php.ini  /etc/php5/fpm/php.ini \
	&& ln -s /app/conf/php-fpm.conf  /etc/php5/fpm/php-fpm.conf 
		
# Volume Shares
VOLUME ["/app/html"]
VOLUME ["/app/sockets"]
VOLUME ["/app/conf"]
VOLUME ["/app/conf.d"]
VOLUME ["/app/logs"]

# Add resources
ADD resources/fpm-bootstrapper.sh /usr/local/bin/fpm-bootstrapper.sh
RUN chmod +x /usr/local/bin/fpm-bootstrapper.sh
ADD resources/php.txt /app/resources/php.txt
ADD resources/docker.txt /app/resources/docker.txt

ENV DEBIAN_FRONTEND newt
ENTRYPOINT ["fpm-bootstrapper.sh"]

