#!/bin/bash

set -e

read_secret() {
    if [ ! -r "$1" ]; then
        echo "MariaDB error: secret file is missing or unreadable: $1" >&2
        exit 1
    fi

    tr -d '\r\n' < "$1"
}

MYSQL_PASSWORD="$(read_secret /run/secrets/mysql_wp_password)"
MYSQL_ROOT_PASSWORD="$(read_secret /run/secrets/mysql_root_password)"

: "${MYSQL_DATABASE:?MYSQL_DATABASE is not set}"
: "${MYSQL_USER:?MYSQL_USER is not set}"
: "${MYSQL_PASSWORD:?MYSQL_PASSWORD secret is empty}"
: "${MYSQL_ROOT_PASSWORD:?MYSQL_ROOT_PASSWORD secret is empty}"

mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

chown -R mysql:mysql /var/lib/mysql

if [ ! -d "/var/lib/mysql/mysql" ]; then
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql --skip-test-db
fi

cat <<EOF > /run/mysqld/init.sql
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};

SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${MYSQL_ROOT_PASSWORD}');

CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';

GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';

FLUSH PRIVILEGES;
EOF

chown mysql:mysql /run/mysqld/init.sql
chmod 600 /run/mysqld/init.sql

exec mariadbd --user=mysql --datadir=/var/lib/mysql --init-file=/run/mysqld/init.sql
