FROM debian:bookworm

RUN apt-get update

RUN apt-get install -y mariadb-server mariadb-client

COPY conf/mariadb-server.cnf /etc/mysql/mariadb.conf.d/mariadb-server.cnf

COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

cat <<EOF > /run/mysqld/init.sql
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};

CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';

GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';

FLUSH PRIVILEGES;
EOF