FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    php php-fpm php-mysql php-cli \
    php-curl php-mbstring php-xml php-zip \
    curl ca-certificates tzdata \
 && rm -rf /var/lib/apt/lists/*

RUN sed -i 's|^listen = .*|listen = 9000|' /etc/php/8.2/fpm/pool.d/www.conf

WORKDIR /var/www/wordpress
RUN curl -O https://wordpress.org/latest.tar.gz \
 && tar -xzf latest.tar.gz --strip-components=1 \
 && rm latest.tar.gz

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
 && chmod +x wp-cli.phar \
 && mv wp-cli.phar /usr/local/bin/wp

COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod 755 /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# FROM debian:bookworm-slim

# ENV DEBIAN_FRONTEND=noninteractive

# RUN apt-get update && apt-get install -y --no-install-recommends \
#     php php-fpm php-mysql php-cli \
#     php-curl php-mbstring php-xml php-zip \
#     curl bash less mariadb-client ca-certificates tzdata \
#  && rm -rf /var/lib/apt/lists/*

# RUN which php-fpm || echo "php-fpm not found"
# RUN ls -l /usr/sbin/php* || echo "No php-fpm binaries found"

# RUN mkdir -p /var/www/wordpress

# WORKDIR /var/www/wordpress
# RUN curl -O https://wordpress.org/latest.tar.gz \
#  && tar -xzf latest.tar.gz --strip-components=1 \
#  && rm latest.tar.gz

# RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
#  && chmod +x wp-cli.phar \
#  && mv wp-cli.phar /usr/local/bin/wp

# COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
# RUN chmod +x /usr/local/bin/entrypoint.sh

# EXPOSE 9000

# ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
