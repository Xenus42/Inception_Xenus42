#!/bin/bash

set -e

: "${DOMAIN_NAME:?DOMAIN_NAME is not set}"

SSL_DIR="/etc/nginx/ssl"
SSL_KEY="${SSL_DIR}/nginx.key"
SSL_CRT="${SSL_DIR}/nginx.crt"

mkdir -p "${SSL_DIR}"

if [ ! -f "${SSL_KEY}" ] || [ ! -f "${SSL_CRT}" ]; then
    openssl req -x509 -nodes -days 365 \
        -newkey rsa:2048 \
        -keyout "${SSL_KEY}" \
        -out "${SSL_CRT}" \
        -subj "/CN=${DOMAIN_NAME}"

    chmod 600 "${SSL_KEY}"
    chmod 644 "${SSL_CRT}"
fi

exec nginx -g "daemon off;"
