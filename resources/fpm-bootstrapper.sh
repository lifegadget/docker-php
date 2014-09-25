#!/bin/bash
cat /app/resources/php.txt
echo "";
cat /app/resources/docker.txt
echo "";
echo "";
php5-fpm -c /app/conf/php.ini --fpm-config /app/conf/php-fpm.conf "$@" 