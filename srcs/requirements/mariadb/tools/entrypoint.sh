#!/bin/bash
set -e

### 🔐 file_env : permet de lire VAR ou VAR_FILE (ex: MYSQL_PASSWORD ou MYSQL_PASSWORD_FILE)
file_env() {
  var="$1"
  fileVar="${var}_FILE"
  val="$(eval echo \$$var)"
  fileVal="$(eval echo \$$fileVar)"
  if [ -n "$val" ] && [ -n "$fileVal" ]; then
    echo "⚠️  Error: both $var and $fileVar are set. Choose only one." >&2
    exit 1
  fi
  if [ -n "$fileVal" ]; then
    export "$var"="$(< "$fileVal")"
  fi
}

# 🔐 Charger toutes les variables sensibles
file_env MYSQL_ROOT_PASSWORD
file_env MYSQL_DB
file_env MYSQL_USER
file_env MYSQL_PASSWORD

if [ ! -d "/var/lib/mysql/mysql" ]; then
  echo "📦 Initialisation de MariaDB..."

  mariadb-install-db --user=mysql --datadir=/var/lib/mysql --auth-root-authentication-method=normal

  temp_sql="$(mktemp)"
  chmod 600 "$temp_sql"

  {
    echo "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"
    if [ -n "$MYSQL_DB" ]; then
      echo "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DB}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    fi
    if [ -n "$MYSQL_USER" ] && [ -n "$MYSQL_PASSWORD" ]; then
      echo "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
      echo "GRANT ALL PRIVILEGES ON \`${MYSQL_DB}\`.* TO '${MYSQL_USER}'@'%';"
    fi
    echo "FLUSH PRIVILEGES;"
  } > "$temp_sql"

  echo "🚀 Exécution des requêtes d'init..."
  mysqld --user=mysql --bootstrap --datadir=/var/lib/mysql < "$temp_sql"
  rm -f "$temp_sql"
else
  echo "✅ MariaDB déjà initialisé, on ne refait pas."
fi

echo "✅ Lancement du serveur MariaDB..."
exec "$@"
