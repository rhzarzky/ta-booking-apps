<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Schedule extends Model
{
    use HasFactory;
    protected $table = 'schedules';
    protected $fillable = ['service_id', 'days', 'date','end_date', 'time'];

    protected $casts = [
        'date' => 'array', 
        'time' => 'array',
        'days' => 'array',
    ];

    public function service()
    {
        return $this->belongsTo(Service::class);
    }
}
