#!/usr/bin/env node

/**
 * MIT © Santiago Greco - fsgreco@hey.com
 * This script fetches a list of active plugins from your production wordpress environment.
 * The goal is to quickly install the same plugins on local environment (matching their version numbers).
 * How it works:
 * Once it retrieves the list it creates a second script (in bash) ready to run: `install-plugins.sh`
 * The script generated consist on a set of instructions to install everything using wp-cli.
 * This second script can be modified or adapted.
 * For more context and information please consult the documentation of the entire project: 
 * `docker-wordpress` at https://github.com/fsgreco/docker-wordpress#sync-plugins-matching-production-environment
 */

/* Native requirements (there's no need to install anything via npm) */
const https = require('https') 
const fs = require('fs')

let hostname, username, appPassword

/* READ ENV VARIABLES: HOSTNAME, USERNAME, APP_PASSWORD */
try {
  const data = fs.readFileSync('../.env', 'utf8')
  
	let envs = data.split('\n')
		.filter(str => !/#/.test(str))
		.filter(str => /=/.test(str))
		.map( singleVar => singleVar.split('=') )
		.map( arr => {
			let sanitizedVal = arr[1].replace(/^"|^'|"$|'$/gm,'')
			arr.pop()
			arr.push(sanitizedVal)
			return arr
		})
	
	const findValue = name => envs.find( couple => couple.find(v => v === name))[1]

	hostname = findValue('HOSTNAME')
	username = findValue('USERNAME')
	appPassword = findValue('APP_PASSWORD')

} catch (err) {
	console.log('ERROR READING ENV VARIABLES')
  throw err
}

let headers = {
	'Authorization': `Basic ${Buffer.from(`${username}:${appPassword}`).toString('base64')}`
}

/* MAKE THE REQUEST TO WP REST API, FETCH THE PLUGIN LIST AND GENERATE THE SECOND SCRIPT */
const request = https.request({ hostname, path:'/wp-json/wp/v2/plugins', port: 443, method: 'GET', headers }, response => {
	response.setEncoding('utf8');
	let returnData = '';

	response.on('data', (chunk) => {
		returnData += chunk;
	})

	response.on('end', () => {
		
		let parsedResponse = JSON.parse(returnData);

		let pluginList = parsedResponse.map( ({plugin,version,status, name}) => ({ plugin,version,status,name }))

		let onlyActivePlugins = pluginList.filter( plgin => plgin.status === 'active')

		const commands = onlyActivePlugins.map(pgin => {
			let pluginSlug = pgin.plugin.replace(/(.*)(\/)(.*)/,'$1')
			return `wp plugin install ${pluginSlug} --version=${pgin.version} --activate \n`
		}).join('')

		const script = '#!/usr/bin/env bash \nsleep 5; \n\n' + commands

		fs.writeFileSync('install-plugins.sh', script)
		fs.chmodSync('install-plugins.sh', 0o775 )

	});

	response.on('error', (error) => {
		throw error;
	});
})
request.end() 
