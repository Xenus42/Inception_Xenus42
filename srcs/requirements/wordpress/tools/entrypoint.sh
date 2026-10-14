#!/bin/sh

set -e

: "${MYSQL_DATABASE:?MYSQL_DATABASE is not set}"
: "${MYSQL_USER:?MYSQL_USER is not set}"
: "${MYSQL_PASSWORD:?MYSQL_PASSWORD is not set}"

: "${LOCAL:?LOCAL is not set}"
: "${WP_DB_HOST:?WP_DB_HOST is not set}"
: "${DOMAIN_NAME:?DOMAIN_NAME is not set}"
: "${WP_SITE_TITLE:?WP_SITE_TITLE is not set}"

: "${WP_ADMIN_NAME:?WP_ADMIN_NAME is not set}"
: "${WP_ADMIN_PASS:?WP_ADMIN_PASS is not set}"
: "${WP_ADMIN_EMAIL:?WP_ADMIN_EMAIL is not set}"

: "${WP_USER_NAME:?WP_USER_NAME is not set}"
: "${WP_USER_PASS:?WP_USER_PASS is not set}"
: "${WP_USER_EMAIL:?WP_USER_EMAIL is not set}"