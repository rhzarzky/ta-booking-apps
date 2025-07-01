<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Notification;
use Illuminate\Notifications\Messages\MailMessage;
use App\Models\Booking;

class ConfirmedBookingMail extends Notification
{
    use Queueable;

    protected $booking;

    public function __construct(Booking $booking)
    {
        $this->booking = $booking;
    }

    public function via($notifiable)
    {
        return ['mail'];
    }

    public function toMail($notifiable)
    {
        return (new MailMessage)
            ->subject("Booking {$this->booking->status}")
            ->greeting("Hi {$notifiable->name},")
            ->line("Your booking for '{$this->booking->service->title}' has been **{$this->booking->status}**.")
            ->line("Date: {$this->booking->date}")
            ->line("Time: {$this->booking->time}")
            ->line("Location: {$this->booking->location}")
            ->when($this->booking->note, fn($msg) => $msg->line("Note: {$this->booking->note}"))
            ->line('Thank you for using our service!');
    }
}

