<?php

namespace App\Listeners;

use App\Events\AppointmentStatusChanged;
use App\Jobs\SendAppointmentNotificationJob;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Support\Facades\Log;

class SendAppointmentStatusNotification implements ShouldQueue
{
    use InteractsWithQueue;

    /**
     * Handle the event.
     */
    public function handle(AppointmentStatusChanged $event): void
    {
        try {
            // Dispatch job untuk mengirim notifikasi
            SendAppointmentNotificationJob::dispatch(
                $event->booking,
                $event->newStatus
            );

            Log::info("SendAppointmentNotificationJob dispatched", [
                'booking_id' => $event->booking->id,
                'new_status' => $event->newStatus,
                'previous_status' => $event->previousStatus
            ]);

        } catch (\Exception $e) {
            Log::error("Failed to dispatch SendAppointmentNotificationJob: " . $e->getMessage(), [
                'booking_id' => $event->booking->id,
                'new_status' => $event->newStatus
            ]);
        }
    }
}
