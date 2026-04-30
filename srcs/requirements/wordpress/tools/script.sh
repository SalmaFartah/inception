#!/bin/bash
# Script reads .env variables and creates wp-config.php

db_pw=$(cat /run/secrets/db_password)
<<<<<<< HEAD
if [ ! -f /var/www/html/wp-config.php ]; then
	# cp -r /var/www/wordpress/* /var/www/html/
	# rm -rf /var/www/wordpress/
	wp config create --dbname=$MARIADB_DATABASE --dbuser=$MARIADB_USER --dbpass=$db_pw --dbhost=mariadb --allow-root --path=/var/www/html
	wp core install --url=$DOMAIN_NAME --title=$SITE_TITLE  --admin_user=$ADMIN --admin_password=$ADMIN_PW --admin_email=$ADMIN_EMAIL \
	--skip-email --allow-root --path=/var/www/html
	wp user create --allow-root --path=/var/www/html bob bob@example.com --user_pass=aaaa --role=subscriber
fi

exec php-fpm8.2 -F
=======
wp_pw=$(cat /run/secrets/wp_pass)
wp_adm_pw=$(cat /run/secrets/wp_adm_pass)

if [ ! -f /var/www/html/wp-config.php ]; then

	cp -r /var/www/html/wordpress/* /var/www/html/ && rm -rf /var/www/html/wordpress/
	wp config create --allow-root --path=/var/www/html/ --dbname=$MARIADB_DATABASE --dbuser=$MARIADB_USER --dbpass=$db_pw --dbhost=mariadb  
	chmod 755 /var/www/html && chown -R www-data:www-data /var/www/html
	wp core install --url=$DOMAIN_NAME --title=$SITE_TITLE  --admin_user=$WP_ADMIN --admin_password=$wp_adm_pw --admin_email=$WP_ADMIN_EMAIL \
	--skip-email --allow-root --path=/var/www/html/
	wp user create --allow-root --path=/var/www/html/ $WP_USER $WP_USER_EMAIL --user_pass=$wp_pw --role=subscriber
fi

exec php-fpm8.2 -F
>>>>>>> structured
