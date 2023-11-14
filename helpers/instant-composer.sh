#!/usr/bin/env bash
# Run an instance of composer matching the wordpress container
# E.g run `helpers/instant-composer`
# Or `helpers/instant-composer container_name your_theme_name` to access via bash
# Or `helpers/instant-composer container_name your_theme_name install` 
docker run --rm --interactive --tty \
  --volumes-from ${1:-'wp-site'} \
  --network container:${1:-'wp-site'} \
	--user "$(id -u)":"$(id -g)" \
	--workdir "/var/www/html/wp-content/themes/${2:-twentytwentythree}" \
  composer "${3:-bash}"
