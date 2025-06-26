<?php

namespace App\Events;

use App\Models\Booking;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class AppointmentStatusChanged
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public $booking;
    public $newStatus;
    public $previousStatus;

    public function __construct(Booking $booking, string $newStatus, string $previousStatus = null)
    {
        $this->booking = $booking;
        $this->newStatus = $newStatus;
        $this->previousStatus = $previousStatus;
    }
}
