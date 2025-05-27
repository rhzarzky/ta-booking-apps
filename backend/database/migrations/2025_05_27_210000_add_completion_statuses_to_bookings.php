<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        if (DB::getDriverName() === 'pgsql') {
            // Untuk PostgreSQL, kita perlu recreate enum type dengan cara yang lebih hati-hati
            DB::transaction(function () {
                // 1. Hapus default value terlebih dahulu
                DB::statement("ALTER TABLE bookings ALTER COLUMN status DROP DEFAULT");
                
                // 2. Buat enum type baru dengan semua nilai
                DB::statement("CREATE TYPE bookings_status_new AS ENUM ('Pending', 'Approved', 'Declined', 'Completed', 'Reviewed', 'Declined Review')");
                
                // 3. Ubah kolom untuk menggunakan enum type baru
                DB::statement("ALTER TABLE bookings ALTER COLUMN status TYPE bookings_status_new USING status::text::bookings_status_new");
                
                // 4. Set default value kembali
                DB::statement("ALTER TABLE bookings ALTER COLUMN status SET DEFAULT 'Pending'::bookings_status_new");
                
                // 5. Hapus enum type lama
                DB::statement("DROP TYPE IF EXISTS bookings_status_check");
                
                // 6. Rename enum type baru ke nama yang benar
                DB::statement("ALTER TYPE bookings_status_new RENAME TO bookings_status_check");
            });
        } else {
            // Untuk MySQL
            Schema::table('bookings', function (Blueprint $table) {
                $table->enum('status', [
                    'Pending', 
                    'Approved', 
                    'Declined', 
                    'Completed', 
                    'Reviewed', 
                    'Declined Review'
                ])->default('Pending')->change();
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        if (DB::getDriverName() === 'pgsql') {
            DB::transaction(function () {
                // Hapus default value
                DB::statement("ALTER TABLE bookings ALTER COLUMN status DROP DEFAULT");
                
                // Kembalikan ke enum type lama
                DB::statement("CREATE TYPE bookings_status_old AS ENUM ('Pending', 'Approved', 'Declined')");
                DB::statement("ALTER TABLE bookings ALTER COLUMN status TYPE bookings_status_old USING status::text::bookings_status_old");
                
                // Set default value kembali
                DB::statement("ALTER TABLE bookings ALTER COLUMN status SET DEFAULT 'Pending'::bookings_status_old");
                
                // Hapus enum type baru
                DB::statement("DROP TYPE bookings_status_check");
                
                // Rename enum type lama
                DB::statement("ALTER TYPE bookings_status_old RENAME TO bookings_status_check");
            });
        } else {
            Schema::table('bookings', function (Blueprint $table) {
                $table->enum('status', ['Pending', 'Approved', 'Declined'])
                      ->default('Pending')
                      ->change();
            });
        }
    }
}; 