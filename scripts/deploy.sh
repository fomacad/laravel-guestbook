#!/usr/bin/env bash
set -euo pipefail
cd /var/www/guestbook

exec 9>/tmp/guestbook-deploy.lock
flock -n 9 || { echo "Another deploy is running"; exit 1; }

composer install --no-dev --optimize-autoloader --no-interaction
php artisan migrate --force
php artisan optimize:clear
php artisan optimize
echo "Deploy finished"
