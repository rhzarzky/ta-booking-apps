<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Service extends Model
{
    use HasFactory;

    protected $table = 'services';

    protected $fillable = [
        'user_id',
        'image',
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

    public function assigned()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function location() 
    {
        return $this->hasOne(Location::class, 'service_id');
    }
}
