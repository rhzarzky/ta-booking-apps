## Stage 1: Composer untuk install dependencies
FROM composer:2 as composer

WORKDIR /app
COPY . .
RUN composer install --ignore-platform-reqs --no-dev -a && composer dump-autoload

## Stage 2: Main PHP Image dengan FrankenPHP
FROM dunglas/frankenphp:latest

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl ffmpeg libpq-dev \
  && install-php-extensions pcntl zip bcmath pdo_pgsql pgsql \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=composer /app /app

# Set permission Laravel
RUN chown -R www-data:www-data storage bootstrap/cache && \
    chmod -R 775 storage bootstrap/cache

# Expose port
EXPOSE 8080

# Jalankan semua perintah saat container run
CMD sh -c "\
  echo '🔗 Checking storage link...' && \
  [ -L public/storage ] || php artisan storage:link && \
  echo '📦 Running migrations...' && \
  php artisan migrate --force && \
  echo '🚀 Starting Octane with FrankenPHP...' && \
  php artisan octane:start --server=frankenphp --host=0.0.0.0 --port=8080 \
"
