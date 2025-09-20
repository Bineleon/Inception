#!/bin/sh
set -eu

DATADIR=/var/lib/mysql
SOCKET=/run/mysqld/mysqld.sock
ROOT_PWD=$(cat /run/secrets/db_root_password)
APP_PWD=$(cat /run/secrets/db_password)

mkdir -p "$(dirname "$SOCKET")" "$DATADIR"
chown -R mysql:mysql "$(dirname "$SOCKET")" "$DATADIR"

if [ -z "$(ls -A "$DATADIR" 2>/dev/null)" ]; then
  mariadb-install-db --user=mysql --datadir="$DATADIR" >/dev/null

  mysqld --socket="$SOCKET" --datadir="$DATADIR" --skip-networking --pid-file=/run/mysqld/mysqld.pid &
  until mariadb-admin --socket="$SOCKET" ping >/dev/null 2>/dev/null; do sleep 0.2; done

  mariadb --socket="$SOCKET" -u root <<-SQL
    CREATE DATABASE wordpress;
    CREATE USER 'wp_user'@'%' IDENTIFIED BY '${APP_PWD}';
    GRANT ALL PRIVILEGES ON wordpress.* TO 'wp_user'@'%';
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PWD}';
    FLUSH PRIVILEGES;
SQL

  mariadb-admin --socket="$SOCKET" shutdown
fi

exec mysqld --datadir="$DATADIR" --socket="$SOCKET"
