FROM debian:bookworm

RUN apt-get update && apt-get install -y wget tar php8.2-fpm php8.2-mysql mariadb-client \
    && mkdir -p /var/www/ && cd /var/www/ && wget https://wordpress.org/latest.tar.gz \
    && tar -xzvf latest.tar.gz && rm -rf latest.tar.gz

RUN chown -R root:root /var/www/wordpress
# RUN chown -R www-data:www-data /var/www/wordpress
# RUN chown -R www-data:www-data /var/www/html/wordpress

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/.

# COPY conf/wp-config.php /var/www/html/.
COPY conf/wp-config.php /tmp/wp-config.php


COPY tools/script.sh .

RUN chmod +x script.sh

ENTRYPOINT ["./script.sh"]

# ENTRYPOINT ["php-fpm8.2", "-F"]
