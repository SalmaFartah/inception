#!/bin/bash
# Script reads .env variables and creates wp-config.php

# db_pw=$(cat /run/secrets/db_password)
if [ ! -f /var/www/html/wp-config.php ]; then
    cp /tmp/wp-config.php /var/www/html/wp-config.php
    cp -r /var/www/wordpress/* /var/www/html/
fi
sed -i "s/database_name_here/$MARIADB_DATABASE/" /var/www/html/wp-config.php
sed -i "s/username_here/$MARIADB_USER/" /var/www/html/wp-config.php
sed -i "s/password_here/$MARIADB_PASSWORD/" /var/www/html/wp-config.php
sed -i "s/localhost/mariadb/" /var/www/html/wp-config.php

exec php-fpm8.2 -F