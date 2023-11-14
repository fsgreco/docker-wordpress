# Wordpress Docker Boilerplate

This is a simple boilerplate to use wordpress on a developer enviroment with docker, orchestrating everything with docker-compose. 

![carbon](https://user-images.githubusercontent.com/22715417/112973115-41f6bd80-9151-11eb-8033-365c9803bcf6.png)


## How to use it:

1. Clone this repository

2. Run `docker-compose up -d`

3. Access to your wordpress at: `http://localhost:8000`

And that's it! :rocket: 

If you already have a website on development/production do this **before** step 2: 

- Place your database dump in `/dump/database.sql.gz` (.sql or .sql.gz - permissions have to be at least `644`)
- Give executive permissions to the update db script: `chmod +x dump/update_db_siteurl_home.sh`
- Place your themes/plugins inside their respective folders[^1]
- Change `YOUR_DOMAIN.dns` inside the `.htaccess` file on `/uploads` folder


This same steps are listed inside the todoist template `csv` (in case you use todoist).

## Suggested workflow

You can place a git submodule inside `themes` folder, in order to have a separate repository to manage your theme.

You can also use a `composer.json` to manage plugins from your theme folder. This could remove the need to use `wp-cli` to install plugins. In that case you can use the script `helpers/instant-composer.sh` once the containers are deployed.

**Another handy idea**:
Sometimes, specially if you have an old WordPress environment installed (with a git project you have already set up), trying to dockerize everything could be painful.  

If you need to try your theme on the fly with docker (maybe try different versions of docker with it) you could set a custom directory for `themes` / `plugins` / `uploads` folder.

So instead of using this repository default directories (like `/wp-content/themes/`) you tell docker to use another directory on your local machine (the one from your project), outside this repository.  

Ex: `$HOME/web/my-old-wp-project/wp-content/themes`.

To achieve this simply create a `.env` file and use the same variables you find inside `.env.example`:

```env
THEMES_DIR=$HOME/web/your_old_wordpress_project/wp-content/themes
PLUGINS_FOLDER=
UPLOADS_DIR=
```

In addition, if you have new paths to match or some complex config to apply, enable the `docker-compose` override function: simply set your override paths inside the file `docker-compose.override.example.yml` and rename the file without "example" in the name. By doing so the next time you run `docker-compose up` the program will take the contents of `docker-compose.override.yml` and apply them on top of your normal docker-compose file.

### Sync plugins matching production environment

I have developed a handy system to match the same plugins that I have on the production environment in localhost environment (this is specially useful since this system syncs the exact plugin version number that the website is actually using).

This command should be ideally launched once the wordpress container is already up. Since plugins will be synched inside that container (unless you run the sync with `test` argument - this will be explained ahead).

##### Set enviroment variables

To achive this you'll only need to set `.env` variables that you found inside `.env.example` file. They are:  

```env
HOSTNAME=your-production-hostname.com
USERNAME=
APP_PASSWORD=withoutspacesifpossible
```
Notice: `HOSTNAME` requires only the hostname without the protocol ('https://').  
In order to obtain the `APP_PASSWORD` value, log in with your username on production, go to _Edit User_ page and create an _application password_ (this is a [new system for making authenticated requests to various WordPress APIs][app-pass-info] - consult the link for more information). You can add this password to the `.env` variable **without the spaces** if possible.

Once you have set your environment variables you're ready to go!

##### Sync plugins

1. Simply run `helpers/sync-plugins.sh` (from the root of the repository)

- **The 'jq' package is needed**  

This script will run an instance of `wp-cli` inside the docker container, from there it will try to install and activate the same plugins you have in production (matching also their version). If the plugin is not found it will simply tell you and skip that single plugin, continuing installing the ones it found.

##### If you are curious on how this works under the hood:

First of all, if you want to supervise which plugins will be installed, then run the script with `test` argument:

```bash
helpers/sync-plugins.sh test
```
It will avoid to launch the wp-cli container, but will provide the commands that container should launch, in order to be modified by you. Take a look at the new file you will find inside `helpers/` directory, it's called `install-plugins.sh`.

This are the instructions to install and activate the same plugins (with same version) on your local environment. Here you can decide which plugins install or not. (You can eventually put this file inside your theme and add it to your source version control system; **by doing this way you can stop to sync all the plugins everytime** ;)

Under the hood `sync-plugins.sh` will fetch and retrieve a list of active plugins in production (thanks to the WP REST API), then it will generate a new script (`install-plugins.sh`) that will appear inside `helpers/`. 

This second script is only a set of instructions for `wp-cli` to install this list of plugins (with exact version that you have on production). 

Subsequently it will run an instance of `wp-cli` inside a docker container, and inside this container it will execute the `install-plugins.sh` so it will install the specific versions of that plugins and activate them.  

[app-pass-info]: https://make.wordpress.org/core/2020/11/05/application-passwords-integration-guide/ "Application Passwords on Wordpress"

[^1]: There are plenty of options for managing themes or plugins for an existing project, either you can copy files manually to respective directories (maybe pulling everything down from ftp etc...), or you can follow more advanced setups, here, in my [suggested workflow section](#suggested-workflow) I propose a system where you can connect your theme and then sync the plugins to match the exact versions you have in production.

---

## Dealing with permissions

Be aware that Docker Wordpress images are Debian-based, its default user is `www-data` and its user id (aka `UID`) is `33` (same for the group user id: `gid=33`). You'll see the user `www-data` from inside the container.

To work with mounted volumes on your host intance (for ex `/themes`, `/plugins`, `/uploads`), at least add yourself to the same group of the the conteinarized user. So for example you need to add yourself to supplementary group `33`:

	sudo usermod -aG 33 your-username

(in archlinux the `gid=33` correspond to the `http` group, so the command is equivalent to `sudo chmod -aG http username`)

After that you need to slightly change the permissions on the volume folders you want to work with:

	sudo chmod -R g+w wp-content

In this way your host user will be able to write files inside those folders (even on ones created by the container user), because you'll share the same group (and with the above commend you're giving write group permissions to those files). 

The only caveat is that every time your container creates a file (saying you install a new plugin from the wordpress containerized instance interface) this file will have `33:33` user owner without group permissions, so you could need to do that `chmod` command above again.

### Why this happens: 

Depending on the distribution your're using docker (**the HOST instance**) you could have other user names for the same `UID` and `GID`. So if you run `ls -al` from outside the container you'll see for example `http` user as the owner of the files, instead of `www-data` (on the contrary you'll see `www-data` if you do an `ls -al` from inside the container), this happens because linux reads the user id (UID) and Group Id (GID) values, no matter the username.

There is a more customizable way to deal with this, in case you need it.

### Customizing permissions

If you constantly need to modify files created from inside the container, you can customize permissions choosing to use a custom Dockerfile for the WordPress Image. It will change the default image user `UID` beforehand.

If that's your choice enable `Dockerfile.website` as the image for the `wordpress` container in the `docker-compose` configuration. 

```yml
  wordpress:
    build:
      context: .
      dockerfile: Dockerfile.website
      args:
        user_id: ${UID:-1000}
```
This will set `1000` as the UID for the default `www-data` user (in this case matching the Archlinux default user id). If you're using a different distro and by any change your UID is different this configuration should already take the env variable UID and adapt everything for you. In case it doesn't work modify `user_id` inside `docker-compose` to match your actual UID. e.g: `user_id: 1001`.
