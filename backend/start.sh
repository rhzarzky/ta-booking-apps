#!/bin/sh

echo "📦 Running migrations..."
php artisan migrate --force

echo "🔗 Ensuring storage link exists..."
if [ ! -L "/app/public/storage" ]; then
  php artisan storage:link
fi

echo "🚀 Starting Laravel server..."
php artisan serve --host=0.0.0.0 --port=8080
