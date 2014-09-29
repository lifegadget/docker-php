#PHP Docker Container
> lifegadget/docker-php [[container](https://registry.hub.docker.com/u/lifegadget/docker-php/)]

## Introduction

This is meant as a way to provide the PHP through a running FPM/FastCGI architecture. Also, while it can be turned off, this PHP installation has Couchbase 2.0 API library installed for easy connection to Couchbase databases.

While not necessary to use with these other containers, both of the following cooperate to create a full stack and follow similar naming conventions:

- NGINX Webserver - [lifegadget/docker-nginx](https://github.com/lifegadget/docker-nginx)
- Couchbase Server - [lifegadget/docker-coachbase](https://github.com/lifegadget/docker-couchbase)

Feel free to use and we are happy to accept PR's if you have ideas you feel would be generally reusable.

## Usage ##

- **Basic usage:**
	
		sudo docker run -d lifegadget/docker-php

	This will get you up and running with a default server configuration:

	- [php.ini](https://github.com/lifegadget/docker-php/blob/master/resources/php.ini)
	- [php-fpm.conf](https://github.com/lifegadget/docker-php/blob/master/resources/php-fpm.conf)

	This configuration, in summary, gives you a "pool" listening on port 9000 with it's root content pointed to the container's `/app/content` directory. In this basic configuration, there are two PHP scripts provided out-of-the-box which are meant just to give you a sense for the environment/configuration:

	- `index.php` - this provides a print out of PHP's well known `phpinfo()` function
	- `server.php` - this provides a listing of all `$_SERVER` variables passed into FPM

	If you're using this in conjunction with `lifegadget/docker-nginx` then these two PHP scripts will be available off the "fpm" root (aka, `http://localhost/fpm`). Enjoy you're done ... but you're going to probably at least put in your own content, right? Turn to the advanced section (which isn't really that advance for that and more).

- **Advanced usage:**

	You can progressively take over responsiblities for various parts of the configuration, including:

	- `content` - this is more than likely the place where you'll want to take control and specify a directory on the host system which represents the root of the content for your site. This will be internally hosted at `/app/content`. So let's assume for a moment that your host machine has a directory called `/container/content` you would then add the following parameter to your run command:
	
		````bash
		-v /container/content:/app/content
		````

		Now your script content is live. That means that handy index.php and server.php we talked about are gone but I'm sure you have far more interesting things you'd like to be doing. 
	
	- `conf.d` - you can take over the `conf.d` directory which is used to specify fpm "pools"; any file with named *.conf will be picked up and used as part of the FPM configuration. Choosing this will mean that the [default service configuration](https://github.com/lifegadget/docker-php/blob/master/resources/default.conf) will go no longer be used.
	-  `conf` - if you want complete control over the configuration you can do this too by taking over all the main [php-fpm.conf](https://github.com/lifegadget/docker-php/blob/master/resources/php-fpm.conf) file.
	-  `logs` - you can share a volume with the container for log files. This doesn't mean the host has any responsibilities for this directory but rather it can view log files that the container has created. Typically an FPM installation has a `php-fpm.log` file (which is rather dull) and then would also have a `php_errors.log` file if any errors were encountered.
	- `sockets` - if you want to share your pool using Unix sockets then you should do a volume with your host so you can put the socket file for other interested parties.
	
	So let's assume that you want your own content and you're interested in gaining visibility to logs from the host, you'd type:

	````bash
	sudo docker run -d lifegadget/docker-php  \
		-v /container/content:/app/content \
		-v /container/logs:/app/logs
	````

## Versions ##

For every major branch of PHP (e.g., 5.5.x, 5.6.x, etc.) there will be a branch in github and you can pick up the latest version by using the Docker tag associated with this branch. For minor versions there will be tags in the branch which are also made available to Docker. Versions currently are:

- `5.5`
	- `5.5.17`

Feel free to PR an update if we're not keeping up.


## License ##

This Dockerfile is free to use and is covered under the MIT license. 

The MIT License (MIT)

Copyright © 2014 LifeGadget Ltd, http://lifegadget.co

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.










### Automated Image for Docker

> Developed by [LifeGadget](http://lifegadget.co) for [LifeGadget](http://lifegadget.co) but anyone is welcome to use
> 

## Warning ##

This documentation is a well ahead of the implementation. This is an active work-in-progress and this warning will be removed once things have stablized (or at least the implementation has caught up to the documentation). 

## Overview ##

This automated-builder produces a docker image that runs:

- PHP
- FPM (socket and TCP connections)

It is meant to work together seemlessly with the NGINX reverse proxy services and should work equally as well with Apache 2.4+ reverse proxies (although this the latter is not tested).


## Usage ##

### Run / Start

For those on *\*nix* systems it usually makes sense to connect your NGINX or Apache webserver to a Unix socket rather than a TCP port. In either case you should make a conscious choice and then configure accordingly. Configuration is done in two places:

- FPM Pool Configuration Files

	Typically you would create a configuration file per FPM pool and put it into the "pool.d" directory so that FPM would pick it up. With this container you have two choices:

	1. Container managed

		If you're running a single pool -- which is often the case -- then you can simply set either the `FPM_SOCKET_DIRECTORY` environment or the `FPM_PORT_variable and a reasonable default pool configuration will be built for you using Unix sockets. variable to either `port` or `socket` in the Docker *run* command and the configuration file will be automagically created for you by the container. Blamo. 

		Here's an example of setting it to run a single socket-connected application:

		````bash
		# Specify where on host system to put Unix sockets
		FPM_SOCKET_DIRECTORY=/host/path/to/sockets
		# Just do it
		sudo docker run -d \
			-v $FPM_SOCKET_DIRECTORY=/etc/php5/fpm/sockets \
			--name=MY_APP -t lifegadget/docker-php 
		````

		

	1. Host configured

		If you're running multiple pools, want to have detailed control over pool parameters, or just suffer from control issues then you'll want to set a volume share with something like the following added to the Docker *run* command:

			# Specify a host directory for your pool configuration files
			FPM_POOL_DIRECTORY=/path/to/pools
			# Docker run
			
		> In order to run in "host configured" mode you'll need to ensure that neither `FPM_SOCKET` or `FPM_PORT` are set.


- Docker Run Configuration

The variation will take place primarily with configuring your FPM-pool configuration files. On your host you'll choose a directory -- let's assume `/path/to/pools` for demonstration purposes -- and then put one or more configuration files (typically one per service) in there that will look something like:
 
- `/path/to/pools/socket-service.ini`

	````bash
	[socketservice]
	; keep in mind file structure should be 
	; from the perspective of the container not host filesystem
	; this is not ideal as it forces implementation details of container to host
	; but for now that is the way it is ... live with it
	listen = /etc/php5/fpm/sockets/socket-service.socket
	listen.mode = 0666
	pm = dynamic
	pm.max_children = 10
	pm.start_servers = 3
	pm.min_spare_servers = 2
	pm.max_spare_servers = 5
	````

- `/path/to/pools/tcp-service.ini`

	````bash
	[tcpservice]
	listen = 127.0.0.1:5000
	pm = dynamic
	pm.max_children = 10
	pm.start_servers = 3
	pm.min_spare_servers = 2
	pm.max_spare_servers = 5
	````

Once configured you'll want to run the following:

````bash
# Give your container a meaningful name
FPM_CONTAINER=PHP_FPM
# The host's root directory for serving content
FPM_WEBSITE_ROOT=/path/to/website
# Specify a host directory for your pool configuration files
FPM_POOL_DIRECTORY=/path/to/pools
# Specify a host directory for socket files
FPM_SOCKET_DIRECTORY=/path/to/sockets

# Unix Sockets
sudo docker run -d \
	--name=$FPM_CONTAINER -t lifegadget/docker-php \
	-v $FPM_WEBSITE_ROOT:/website \
	-v $FPM_POOL_DIRECTORY=/etc/php5/fpm/pool.d 
	-v $FPM_SOCKET_DIRECTORY=/etc/php5/fpm/sockets 
	
# TCP Sockets
sudo docker run -d \
	--name=$FPM_CONTAINER -t lifegadget/docker-php \
	-v $FPM_WEBSITE_ROOT:/website \
	-v $FPM_POOL_DIRECTORY=/etc/php5/fpm/pool.d 
	-p 1080:5000 -p 1081:6000 -p 1082:7000 
````

> **Note:** the TCP Sockets example assumes three pools are configured and that they are internal to the container configured on ports 5000, 6000, and 7000 respectively. In the case of the Unix Sockets, where having more than one pool configured would result in multiple socket files, there is no need to state anything in the docker *run* command because we're simply pointing to the directory in which the socket files will reside. The names of of these sockets will be  

At this point your container should be running (check using `sudo docker ps`) and the FPM services -- whether through TCP or Unix sockets -- should be available to the host to be consumed by NGINX, Apache, or some other service.


###Management

- Generic Container Management	

	````bash
	# Start
	sudo docker start $FPM_CONTAINER
	# Stop
	sudo docker stop $FPM_CONTAINER
	# Restart
	sudo docker restart $FPM_CONTAINER
	# Container details
	sudo docker inspect $FPM_CONTAINER
	# Logging/STDOUT of container
	sudo docker logs $FPM_CONTAINER
	````

- Exposed Command Interface

	> TBD

## Versions / Tags ##

Various versions will be made available. Docker tags include:

- `latest`: the latest version checked into the '5.6' features branch
- `stable`: the latest version checked into the '5.5' features branch
- `5.6`: same as 'latest'
- `5.5`: same as 'stable'
- `5.4`: the latest release in the 5.4 features branch
- `5.3`: the latest release in the 5.3 features branch 

> **Note:** the 5.3 and 5.4 feature branches don't have much of a functional goal for us right now so these are effectively untested


## License

The MIT License (MIT)

Copyright © 2014 LifeGadget Ltd, [http://lifegadget.co](http://lifegadget.co)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.