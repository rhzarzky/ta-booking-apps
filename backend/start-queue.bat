@echo off
echo Starting Laravel Queue Worker...
echo Press Ctrl+C to stop

cd /d "c:\laragon\www\Appointly\booking-test\booking-test\backend"
php artisan queue:work --verbose --tries=3 --timeout=90
