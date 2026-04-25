#!/bin/bash
# Script reads .env variables and creates wp-config.php

db_pw=$(cat /run/secrets/db_password)
if [ ! -f /var/www/html/wp-config.php ]; then
	# cp -r /var/www/wordpress/* /var/www/html/
	# rm -rf /var/www/wordpress/
	wp config create --dbname=$MARIADB_DATABASE --dbuser=$MARIADB_USER --dbpass=$db_pw --dbhost=mariadb --allow-root --path=/var/www/html
	wp core install --url=$DOMAIN_NAME --title=$SITE_TITLE  --admin_user=$ADMIN --admin_password=$ADMIN_PW --admin_email=$ADMIN_EMAIL \
	--skip-email --allow-root --path=/var/www/html
	wp user create --allow-root --path=/var/www/html bob bob@example.com --user_pass=aaaa --role=subscriber
fi

exec php-fpm8.2 -F