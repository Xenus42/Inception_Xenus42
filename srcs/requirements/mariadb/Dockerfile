FROM debian:bookworm

RUN apt-get update

RUN apt-get install -y mariadb-server mariadb-client

COPY conf/mariadb-server.cnf /etc/mysql/mariadb.conf.d/mariadb-server.cnf

COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

