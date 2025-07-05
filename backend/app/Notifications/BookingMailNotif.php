<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Notification;
use Illuminate\Notifications\Messages\MailMessage;
use App\Models\Booking;

class BookingMailNotif extends Notification
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
            ->subject("New Booking Notification")
            ->greeting("Hi {$notifiable->name},")
            ->line("A new booking has been made by **{$this->booking->user->name}**.")
            ->line("Service: {$this->booking->service->title}")
            ->line("Status: {$this->booking->status}")
            ->line("Date: {$this->booking->date}")
            ->line("Time: {$this->booking->time}")
            ->line("Location: {$this->booking->location}")
            ->line('Please log in to the admin panel to verify or manage this booking.');
    }
}

