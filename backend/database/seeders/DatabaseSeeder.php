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
            'show user', 'create user', 'edit user', 'delete user', 
            'show permission', 'show role', 'create role', 'delete role', 
            'edit role','assign role', 'assign permission', 'assign permission role',
            'show all service', 'create service', 'edit service', 'delete service',
            'show all booking', 'confirm booking'
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
                'status' => 'Active'
            ]
        );
        $adminRole = Role::where('name', 'admin')->first();
        $userRole = Role::where('name', 'user')->first();

        // Assign the 'admin' role to the admin user
        $adminUser->assignRole('admin');
        $adminUser->syncPermissions($permissions); // Assign all permissions
        $adminRole->syncPermissions($permissions); // Ensure the role has all permissions
        $userRole->syncPermissions(['show all service']); // Assign basic permissions to user role
        Log::info("Admin user created.");
    }
}
