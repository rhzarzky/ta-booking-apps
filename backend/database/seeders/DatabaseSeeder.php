<?php

namespace Database\Seeders;

use App\Models\User;
use Spatie\Permission\Models\Role;
use Spatie\Permission\Models\Permission;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run()
    {
        $permissions = [
            'show user', 'show permission', 'show role', 'create role',
            'assign role', 'assign permission',
        ];

        foreach ($permissions as $permission) {
            Permission::firstOrCreate(['name' => $permission, 'guard_name' => 'api']);
            Log::info("Permission '{$permission}' created or already exists");
        }

        Role::firstOrCreate(['name' => 'admin']);
        Role::firstOrCreate(['name' => 'user']);

        // Find the admin user (or create one if doesn't exist)
        $adminUser = User::firstOrCreate(
            ['email' => 'admin@gmail.com'],
            [
                'name' => 'Administrator',
                'password' => Hash::make('admin123'),
            ]
        );

        // Assign the 'admin' role to the admin user
        $adminUser->assignRole('admin');
        $adminUser->syncPermissions($permissions); // Assign all permissions
        Log::info("Admin user created.");
    }
}
