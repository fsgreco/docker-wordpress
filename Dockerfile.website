FROM wordpress:php8.1-apache

#RUN docker-php-ext-install mysqli pdo pdo_mysql

#COPY ./custom.ini $PHP_INI_DIR/conf.d/
RUN echo "memory_limit=2048M \nmax_execution_time=600 \nupload_max_filesize=64M" > $PHP_INI_DIR/conf.d/custom.ini

# Syncronize permissions: give the container user (www-data) the same UID and GID as your host user (in archilinux is 1000)
ARG user_id=1000
RUN usermod -u $user_id www-data
RUN groupmod -g $user_id www-data

# Change permissions on the whole project folder 
RUN chmod -R g+r /var/www/html/

USER www-data

#CMD ["apache2-foreground"]
