#!/usr/bin/env bash

# MIT © Santiago Greco - fsgreco@hey.com
# This script aims to install the same active plugins on production in your local wp container
# It do so by fetching the list of plugins to be installed and generating the instructions to do so.
# Once it has the instructions it launches an instance of `wp-cli` via docker, where it applies them.
#
# The instructions for wp-cli will be already setted thanks to `generate-plugins-script.sh`
# For more context and information please consult the documentation of the entire project:
# docker-wordpress - https://github.com/fsgreco/docker-wordpress#sync-plugins

PARENT_DIR="$(dirname "$(dirname "$(realpath "$0")")")"
INSTALL_SCRIPT="$PARENT_DIR/helpers/install-plugins.sh"

if [ ! -f "$INSTALL_SCRIPT" ]; then

  source "$PARENT_DIR/helpers/generate-plugin-script.sh"
  generate_plugin_list
  echo "✅  Created install-plugins.sh inside $PARENT_DIR/helpers"

else 
  echo "🔄  Skipping fetching plugins from production - install-plugins.sh already exist."
fi

if [ "$1" = "test" ]; then exit 0; fi

echo "Running docker instance to install plugins inside the container..."

docker run -it --rm \
    --volumes-from ${1:-'wp-site'} \
    --network container:${1:-'wp-site'} \
    -e WORDPRESS_DB_HOST=db:3306 \
    -e WORDPRESS_DB_USER=wp_user \
    -e WORDPRESS_DB_PASSWORD=wp_pass \
    -e WORDPRESS_DB_NAME=wp_wordpress \
    --mount type=bind,source="$INSTALL_SCRIPT",target=/var/www/html/install-plugins.sh \
    --user "$(id -u)":"$(id -g)" \
    wordpress:cli /var/www/html/install-plugins.sh
