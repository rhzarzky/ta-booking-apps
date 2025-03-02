<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Service extends Model
{
    use HasFactory;

    protected $table = 'services';

    protected $fillable = [
        'image',
        'title',
        'description',
        'option', 
        'start_date', 
        'days', 
        'end_date', 
    ];

    protected $casts = [
        'option' => 'array', 
        'days' => 'array',   
    ];
}
