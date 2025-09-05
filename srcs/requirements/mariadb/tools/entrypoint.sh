#!/bin/sh
set -eu

DATADIR="${MARIADB_DATA_DIR:-/var/lib/mysql}"
SOCKET="${MARIADB_SOCKET:-/run/mysqld/mysqld.sock}"

ROOT_PWD_FILE="/run/secrets/db_root_password"
APP_PWD_FILE="/run/secrets/db_password"

if [ ! -f "$ROOT_PWD_FILE" ] || [ ! -f "$APP_PWD_FILE" ]; then
  echo "Missing secrets. Ensure docker-compose 'secrets:' maps db_root_password.txt and db_password.txt" >&2
  exit 1
fi

ROOT_PWD="$(cat "$ROOT_PWD_FILE")"
APP_PWD="$(cat "$APP_PWD_FILE")"

: "${MARIADB_DATABASE:?Missing MARIADB_DATABASE in env}"
: "${MARIADB_USER:?Missing MARIADB_USER in env}"

mkdir -p "$(dirname "$SOCKET")" "$DATADIR"
chown -R mysql:mysql "$(dirname "$SOCKET")" "$DATADIR"

start_temp_server() {
  mysqld \
	--socket="$SOCKET" \
	--datadir="$DATADIR" \
	--skip-networking \
	--pid-file=/run/mysqld/mysqld.pid &

  i=0
  until mariadb-admin --socket="$SOCKET" ping >/dev/null 2>&1; do
	i=$((i+1))
	if [ $i -gt 50 ]; then
	  echo "mysqld failed to start (bootstrap)" >&2
	  exit 1
	fi
	sleep 0.2
  done
}

stop_temp_server() {
  mariadb-admin --socket="$SOCKET" shutdown 2>/dev/null \
  || mariadb-admin --socket="$SOCKET" -uroot -p"$ROOT_PWD" shutdown 2>/dev/null \
  || killall mysqld 2>/dev/null || true
}

if [ -z "$(ls -A "$DATADIR" 2>/dev/null)" ]; then
  echo "Initializing database files in $DATADIR ..."
  
  mariadb-install-db --user=mysql --datadir="$DATADIR" --skip-test-db >/dev/null

  start_temp_server

  echo "Creating initial database, user and privileges ..."
  mariadb --socket="$SOCKET" -uroot <<-SQL

	CREATE DATABASE IF NOT EXISTS \`${MARIADB_DATABASE}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
	CREATE USER IF NOT EXISTS \`${MARIADB_USER}\`@'%' IDENTIFIED BY '${APP_PWD}';
	GRANT ALL PRIVILEGES ON \`${MARIADB_DATABASE}\`.* TO \`${MARIADB_USER}\`@'%';

	DELETE FROM mysql.user WHERE user='';

	ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PWD}';
	FLUSH PRIVILEGES;
SQL

  stop_temp_server
  echo "Initialization completed."
else
  echo "Existing database detected at $DATADIR — skipping init."
fi

echo "Starting mysqld..."
exec mysqld --datadir="$DATADIR" --socket="$SOCKET"
