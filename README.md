# Wordpress Docker Boilerplate

This is a simple boilerplate to use wordpress on a developer enviroment with docker, orchestrating everything with docker-compose. 

## How to use it:

1. Clone this repository

2. If you already have a website on development/production: 

	- Place your database dump inside `/dump` folder (.sql or .gz)
	- Place your themes/plugins inside their respective folders[^1]
	- Change `YOUR_DOMAIN.dns` inside the `.htaccess` file on `/uploads` folder

3. Run `docker-compose up -d`

4. If you load your database dump
	- Access to phpmyadmin at `http://localhost:8081` url
	- Then change the `siteurl` and `home` values inside `wp_options` table to `http://localhost:8000`

5. Access to your wordpress at: `http://localhost:8000`

And that's it! :rocket: 

This same steps are replicated inside the todoist template `csv` (in case you use todoist).

### Suggested workflow

You can place a git submodule inside `themes` folder, in order to have a separate repository to manage your theme.

You can also use a `composer.json` to manage plugins from your theme folder. This could remove the need to use `wp-cli` to install plugins. 


[^1]: ##suggested-workflow "Suggested workflow"

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
```
This will set `1000` as the UID for the default `www-data` user (in this case matching the Archlinux default user id).

### Using wp-cli
If you need wp-cli you decomment the configuration inside docker-compose file.
Then choose your user according to the wordpress container config:
- `user: xfs` # if you're using default wordpress images | this user will match 33:33 (uid:gid)
- `user: "1000:33"` # if you use Dockerfile.website | matches www-data uid=1000

After this you could use `wp-cli` activating this through compose file:

	docker-compose run --rm cli wp your-wp-cli-commands

