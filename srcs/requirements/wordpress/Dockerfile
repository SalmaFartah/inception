FROM debian:bookworm

RUN apt-get update && apt-get install -y wget tar php8.2-fpm php8.2-mysql mariadb-client curl \
    && mkdir -p /var/www/html && cd /var/www/html && wget https://wordpress.org/latest.tar.gz \
    && tar -xzvf latest.tar.gz && rm -rf latest.tar.gz\
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# install wp cli 
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/.

COPY tools/script.sh .

RUN chmod +x script.sh

ENTRYPOINT ["./script.sh"]
