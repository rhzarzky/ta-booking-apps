## Run Project Backend

1. Buka direktori `backend`:
    ```bash
    cd backend
    ```
2. Install dependensi Composer:
    ```bash
    composer install
    ```
3. Jalankan migrasi dan seed database:
    ```bash
    php artisan migrate
    php artisan db:seed
    ```
4. Jalankan server Laravel:
    ```bash
    php artisan serve
    ```
