#!/bin/sh
set -e

WP_PATH="/var/www/wordpress"
WP_CONFIG="$WP_PATH/wp-config.php"

ROOT_PWD=$(cat /run/secrets/db_root_password)
DB_PWD=$(cat /run/secrets/db_password)
WP_ADMIN_PWD=$(cat /run/secrets/wp_admin_password)
WP_USER_PWD=$(cat /run/secrets/wp_user_password)

if [ ! -f "$WP_PATH/wp-settings.php" ]; then
  wp core download --path="$WP_PATH" --allow-root
fi

if [ ! -f "$WP_CONFIG" ]; then
  wp config create --path="$WP_PATH" \
    --dbname="$MARIADB_DATABASE" \
    --dbuser="$MARIADB_USER" \
    --dbpass="$DB_PWD" \
    --dbhost="$WORDPRESS_DB_HOST" \
    --allow-root

  wp core install --path="$WP_PATH" \
    --url="https://${DOMAIN_NAME}" \
    --title="$WP_SITE_TITLE" \
    --admin_user="$WP_ADMIN_USER" \
    --admin_password="$WP_ADMIN_PWD" \
    --admin_email="$WP_ADMIN_EMAIL" \
    --skip-email \
    --allow-root

  wp user create "$WP_USER" "user@example.com" \
    --user_pass="$WP_USER_PWD" \
    --role=subscriber \
    --allow-root
fi

exec php-fpm8.2 -F
