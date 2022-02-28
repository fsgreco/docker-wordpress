#!/usr/bin/env bash

# MIT © Santiago Greco - fsgreco@hey.com
# This script launches an instance of wp-cli via docker, it then executes a set of instructions
# The instructions for wp-cli are already setted thanks to `generate-plugins-script.js`
# For more context and information please consult the documentation of the entire project:
# docker-wordpress - https://github.com/fsgreco/docker-wordpress#sync-plugins

docker run -it --rm \
    --volumes-from ${1:-'wp-site'} \
    --network container:${1:-'wp-site'} \
		-e WORDPRESS_DB_HOST=db:3306 \
    -e WORDPRESS_DB_USER=wp_user \
    -e WORDPRESS_DB_PASSWORD=wp_pass \
    -e WORDPRESS_DB_NAME=wp_wordpress \
    --mount type=bind,source="$(pwd)"/install-plugins.sh,target=/var/www/html/install-plugins.sh \
    --user=${2:-1000}:${3:-1000} \
    wordpress:cli-php7.4 /var/www/html/install-plugins.sh
