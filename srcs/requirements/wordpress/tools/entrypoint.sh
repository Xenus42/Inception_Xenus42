#!/bin/sh

set -eu

read_secret() {
    if [ ! -r "$1" ]; then
        echo "WordPress error: secret file is missing or unreadable: $1" >&2
        exit 1
    fi

    tr -d '\r\n' < "$1"
}

MYSQL_PASSWORD="$(read_secret /run/secrets/mysql_wp_password)"

WP_ADMIN_PASS="$(read_secret /run/secrets/wp_admin_pass)"

WP_USER_PASS="$(read_secret /run/secrets/wp_user_pass)"

: "${LOCAL:?LOCAL is not set}"
: "${WP_DB_HOST:?WP_DB_HOST is not set}"
: "${DOMAIN_NAME:?DOMAIN_NAME is not set}"
: "${WP_SITE_TITLE:?WP_SITE_TITLE is not set}"

: "${MYSQL_DATABASE:?MYSQL_DATABASE is not set}"
: "${MYSQL_USER:?MYSQL_USER is not set}"
: "${MYSQL_PASSWORD:?MYSQL_PASSWORD secret is empty}"
: "${WP_ADMIN_NAME:?WP_ADMIN_NAME is not set}"
: "${WP_ADMIN_PASS:?WP_ADMIN_PASS secret is empty}"
: "${WP_ADMIN_EMAIL:?WP_ADMIN_EMAIL is not set}"
: "${WP_USER_NAME:?WP_USER_NAME is not set}"
: "${WP_USER_PASS:?WP_USER_PASS secret is empty}"
: "${WP_USER_EMAIL:?WP_USER_EMAIL is not set}"

WP_URL="https://${DOMAIN_NAME}"

mkdir -p /var/www/html

if [ ! -f /var/www/html/wp-settings.php ]; then
    wp core download \
        --locale="$LOCAL" \
        --path=/var/www/html \
        --allow-root
fi

if [ ! -f /var/www/html/wp-config.php ]; then
    wp config create \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$MYSQL_PASSWORD" \
        --dbhost="$WP_DB_HOST" \
        --path=/var/www/html \
        --skip-check \
        --allow-root
fi

if ! wp core is-installed --path=/var/www/html --allow-root >/dev/null 2>&1; then
    wp core install \
        --url="$WP_URL" \
        --title="$WP_SITE_TITLE" \
        --admin_user="$WP_ADMIN_NAME" \
        --admin_password="$WP_ADMIN_PASS" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --locale="$LOCAL" \
        --skip-email \
        --path=/var/www/html \
        --allow-root
fi

if ! wp user get "$WP_USER_NAME" --path=/var/www/html --allow-root >/dev/null 2>&1; then
    wp user create \
        "$WP_USER_NAME" \
        "$WP_USER_EMAIL" \
        --role=author \
        --user_pass="$WP_USER_PASS" \
        --path=/var/www/html \
        --allow-root
fi

mkdir -p /var/www/html/wp-content/uploads
chown -R www-data:www-data /var/www/html/wp-content/uploads

exec php-fpm8.2 -F
