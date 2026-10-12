FROM debian:bookworm

RUN RUN apt-get update && \
    apt-get install -y mariadb-server mariadb-client && \
    rm -rf /var/lib/apt/lists/*

COPY conf/60-inception.cnf /etc/mysql/mariadb.conf.d/60-inception.cnf