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
        'location',
        'title',
        'description',
        'option', 
    ];

    protected $casts = [
        'option' => 'array', 
    ];

    public function schedule()
    {
        return $this->hasOne(Schedule::class, 'service_id');
    }
}
