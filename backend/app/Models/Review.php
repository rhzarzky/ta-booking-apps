<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Carbon\Carbon;

class Review extends Model
{
    use HasFactory;

    protected $fillable = [
        'booking_id',
        'user_id',
        'rating',
        'comment',
        'status',
        'completed_at',
        'review_deadline',
        'reviewed_at'
    ];

    protected $casts = [
        'rating' => 'integer',
        'completed_at' => 'datetime',
        'review_deadline' => 'datetime',
        'reviewed_at' => 'datetime',
    ];

    public function booking()
    {
        return $this->belongsTo(Booking::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function isReviewPeriodActive()
    {
        if (!$this->completed_at) {
            return false;
        }
        
        $deadline = Carbon::parse($this->completed_at)->addHours(72);
        return Carbon::now()->lessThan($deadline);
    }

    public static function getBookingWithReviewStatus($bookingId)
    {
        $booking = Booking::find($bookingId);
        if (!$booking) {
            return null;
        }

        $review = self::where('booking_id', $bookingId)->first();
        
        return [
            'booking' => $booking,
            'review' => $review,
            'review_status' => $review ? $review->status : 'no_review',
            'can_review' => $review ? $review->isReviewPeriodActive() && $review->status === 'pending' : false
        ];
    }
}