#!/usr/bin/env bash 

# MIT © Santiago Greco - fsgreco@hey.com
#
# This script sets a function that fetches a list of active plugins from your production WordPress environment.
# Once it retrieves the list it creates a second script ready to run: `install-plugins.sh`
#
# For more context and information please consult the documentation of the entire project:
# docker-wordpress - https://github.com/fsgreco/docker-wordpress#sync-plugins

if ! command -v jq &> /dev/null; then echo "Please install 'jq'." && exit 1; fi

if [ -f ./.env ]; then
  export $(grep -v '#.*' ./.env | xargs | envsubst )
fi

function generate_plugin_list() {

	URL="https://${HOSTNAME}/wp-json/wp/v2/plugins"

	PLUGIN_LIST=$(curl -s $URL -k -u ${USERNAME}:${APP_PASSWORD} )

	ACTIVE_PLUGINS=$(echo $PLUGIN_LIST | jq 'map( select(.status == "active") )')

	MAPPED_LIST=$(echo $ACTIVE_PLUGINS | jq 'map( { plugin: (.plugin | sub("/.*";"") ), version } )' )

	# Create the script `install-plugins.sh`
	RESULTING_SCRIPT="./helpers/install-plugins.sh"
	echo -e "#!/usr/bin/env bash \nsleep 5; \n" > $RESULTING_SCRIPT
	chmod 775 $RESULTING_SCRIPT

	echo $MAPPED_LIST | jq -c '.[]' | while read i; do # -c breaks the array returns by lines
		package=$(echo $i | jq -j '.plugin')
		version=$(echo $i | jq -j '.version')
		echo "wp plugin install ${package} --version=${version} --activate" >> $RESULTING_SCRIPT
	done
}
