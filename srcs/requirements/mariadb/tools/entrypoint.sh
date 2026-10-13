#!/bin/bash

set -e
: "${MYSQL_DATABASE:?MYSQL_DATABASE n'est pas définie}"
: "${MYSQL_USER:?MYSQL_USER n'est pas défini}"
: "${MYSQL_PASSWORD:?MYSQL_PASSWORD n'est pas défini}"
: "${MYSQL_ROOT_PASSWORD:?MYSQL_ROOT_PASSWORD n'est pas défini}"

mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

chown -R mysql:mysql /var/lib/mysql

if [ ! -d "/var/lib/mysql/mysql" ]; then
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql
fi

cat <<EOF > /run/mysqld/init.sql
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};

CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';

GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';

FLUSH PRIVILEGES;
EOF