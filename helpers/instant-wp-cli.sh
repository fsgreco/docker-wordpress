#!/usr/bin/env bash
# Run an instance of wp-cli matching the wordpress container
docker run -it --rm \
    --volumes-from ${1:-'wp-site'} \
    --network container:${1:-'wp-site'} \
    -e WORDPRESS_DB_HOST=db:3306 \
    -e WORDPRESS_DB_USER=wp_user \
    -e WORDPRESS_DB_PASSWORD=wp_pass \
    -e WORDPRESS_DB_NAME=wp_wordpress \
    --user=${2:-1000}:${3:-1000} \
    wordpress:cli-php7.4 bash
