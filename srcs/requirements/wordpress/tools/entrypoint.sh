#!/bin/sh

set -e

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
    wp core install 
        --url="$WP_URL" 
        --title="$WP_SITE_TITLE" 
        --admin_user="$WP_ADMIN_NAME" 
        --admin_password="$WP_ADMIN_PASS" 
        --admin_email="$WP_ADMIN_EMAIL" 
        --locale="$LOCAL" 
        --skip-email 
        --path=/var/www/html 
        --allow-root
fi