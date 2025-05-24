#!/bin/bash
set -e

cd /var/www

# Install dependencies if vendor directory is empty
if [ ! -d "vendor" ] || [ -z "$(ls -A vendor)" ]; then
    composer install --no-interaction --no-plugins --no-scripts
fi

# Optimize composer autoloader
composer dump-autoload --optimize --no-dev --quiet

# Wait for MySQL to be ready
echo "Waiting for MySQL..."
until nc -z -v -w30 db 3306
do
    echo "Waiting for database connection..."
    sleep 5
done

# Generate app key if not set
php artisan key:generate --no-interaction --force

# Storage link
php artisan storage:link --force

# Clear all caches
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear

# Run migrations
php artisan migrate --force --no-interaction

# Start PHP-FPM
php-fpm
