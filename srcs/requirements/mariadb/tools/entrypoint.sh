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
