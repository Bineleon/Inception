#!/bin/bash
set -e

### 🔐 file_env : charge une variable ou lit depuis un secret
file_env() {
  var="$1"
  fileVar="${var}_FILE"
  val="$(eval echo \$$var)"
  fileVal="$(eval echo \$$fileVar)"
  if [ -n "$val" ] && [ -n "$fileVal" ]; then
    echo "Error: both $var and $fileVar are set" >&2
    exit 1
  fi
  if [ -n "$fileVal" ]; then
    export "$var"="$(< "$fileVal")"
  fi
}

### 🔐 Charger les variables nécessaires
file_env MYSQL_USER
file_env MYSQL_PASSWORD
file_env MYSQL_DB
file_env WP_ADMIN_USER
file_env WP_ADMIN_PASSWORD
file_env WP_ADMIN_EMAIL
file_env WP_TITLE
file_env DOMAIN_NAME

### ⏳ Attendre que MariaDB soit prêt
until mysqladmin ping -h mariadb --silent; do
  echo "Waiting for MariaDB..."
  sleep 2
done

### 📂 Télécharger WordPress si nécessaire
cd /var/www/html

if [ ! -f entrypointig.php ]; then
  echo "Downloading WordPress..."
  wp core download --allow-root

  echo "Creating entrypointig.php..."
  wp config create \
    --dbname="$MYSQL_DB" \
    --dbuser="$MYSQL_USER" \
    --dbpass="$MYSQL_PASSWORD" \
    --dbhost="mariadb:3306" \
    --allow-root

  echo "Installing WordPress..."
  wp core install \
    --url="$DOMAIN_NAME" \
    --title="$WP_TITLE" \
    --admin_user="$WP_ADMIN_USER" \
    --admin_password="$WP_ADMIN_PASSWORD" \
    --admin_email="$WP_ADMIN_EMAIL" \
    --skip-email \
    --allow-root
else
  echo "WordPress already installed. Skipping setup."
fi

### ✅ Lancer php-fpm
exec php-fpm7.4 -F
