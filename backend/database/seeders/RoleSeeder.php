<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class RoleSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run()
    {
        // Create roles if they don't exist
        $adminRole = Role::firstOrCreate(['name' => 'admin']);
        $userRole = Role::firstOrCreate(['name' => 'user']);

        // Find the admin user (or create one if doesn't exist)
        $adminUser = User::firstOrCreate(
            ['email' => 'admin@gmail.com'], // You can set a unique email for the admin
            [
                'name' => 'Administrator',
                'password' => Hash::make('admin123'), // Set a password for the admin
            ]
        );

        // Assign the 'admin' role to the admin user
        $adminUser->assignRole($adminRole);
    }
}
