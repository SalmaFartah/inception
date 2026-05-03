FROM debian:bookworm

RUN apt-get update && apt-get install -y nginx \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY conf/default.conf /etc/nginx/conf.d/default.conf

COPY site/ /var/www/html/

RUN chmod -R 755 /var/www/html && chown -R www-data:www-data /var/www/html

CMD ["nginx", "-g", "daemon off;"]
