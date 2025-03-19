<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Booking extends Model {
    use HasFactory;

    protected $fillable = [
        'service_id', 
        'user_id', 
        'status',
        'option',
        'note',
        'day',
        'time'
    ];

    public function service() {
        return $this->belongsTo(Service::class);
    }

    public function user() {
        return $this->belongsTo(User::class);
    }
}
