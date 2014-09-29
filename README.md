#PHP Docker Container
> lifegadget/docker-php [[container](https://registry.hub.docker.com/u/lifegadget/docker-php/)]

## Introduction

This is meant as a way to provide the PHP through a running FPM/FastCGI architecture. Also, while it can be turned off, this PHP installation has Couchbase 2.0 API library installed for easy connection to Couchbase databases.

While not necessary to use with these other containers, both of the following cooperate to create a full stack and follow similar naming conventions:

- NGINX Webserver - [lifegadget/docker-nginx](https://github.com/lifegadget/docker-nginx)
- Couchbase Server - [lifegadget/docker-couchbase](https://github.com/lifegadget/docker-couchbase)

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
