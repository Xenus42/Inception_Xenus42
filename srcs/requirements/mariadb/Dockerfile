FROM debian:bookworm

RUN apt-get update

RUN apt-get install -y mariadb-server mariadb-client

COPY conf/60-inception.cnf /etc/mysql/mariadb.conf.d/60-inception.cnf

COPY tools/init-db.sh /usr/local/bin/init-db.sh

RUN chmod +x /usr/local/bin/init-db.sh