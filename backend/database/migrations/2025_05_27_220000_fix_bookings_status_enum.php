<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        if (DB::getDriverName() === 'pgsql') {
            // Untuk PostgreSQL, coba tambahkan nilai satu per satu
            try {
                // Cek apakah enum type sudah ada
                $result = DB::select("SELECT typname FROM pg_type WHERE typname = 'bookings_status_check'");
                
                if (!empty($result)) {
                    // Jika enum type sudah ada, coba tambahkan nilai baru
                    $existingValues = DB::select("SELECT enumlabel FROM pg_enum WHERE enumtypid = (SELECT oid FROM pg_type WHERE typname = 'bookings_status_check')");
                    $currentValues = array_column($existingValues, 'enumlabel');
                    
                    // Tambahkan nilai yang belum ada
                    if (!in_array('Completed', $currentValues)) {
                        DB::statement("ALTER TYPE bookings_status_check ADD VALUE 'Completed'");
                    }
                    if (!in_array('Reviewed', $currentValues)) {
                        DB::statement("ALTER TYPE bookings_status_check ADD VALUE 'Reviewed'");
                    }
                    if (!in_array('Declined Review', $currentValues)) {
                        DB::statement("ALTER TYPE bookings_status_check ADD VALUE 'Declined Review'");
                    }
                } else {
                    // Jika enum type belum ada, buat yang baru
                    DB::statement("CREATE TYPE bookings_status_check AS ENUM ('Pending', 'Approved', 'Declined', 'Completed', 'Reviewed', 'Declined Review')");
                    
                    // Update kolom untuk menggunakan enum type
                    DB::statement("ALTER TABLE bookings ALTER COLUMN status TYPE bookings_status_check USING status::text::bookings_status_check");
                    DB::statement("ALTER TABLE bookings ALTER COLUMN status SET DEFAULT 'Pending'::bookings_status_check");
                }
            } catch (\Exception $e) {
                // Jika gagal, log error tapi jangan fail migration
                Log::warning("Failed to update enum type: " . $e->getMessage());
            }
        } else {
            // Untuk MySQL
            try {
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
            } catch (\Exception $e) {
                Log::warning("Failed to update enum for MySQL: " . $e->getMessage());
            }
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Tidak melakukan rollback untuk menghindari masalah
        // Karena menghapus nilai enum yang sudah digunakan bisa berbahaya
        Log::info("Rollback skipped for enum modification to prevent data loss");
    }
}; 