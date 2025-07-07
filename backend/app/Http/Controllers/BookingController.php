<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Notifications\BookingMailNotif;
use App\Notifications\ConfirmedBookingMail;
use Illuminate\Http\Request;
use App\Models\Booking;
use App\Models\Service;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Str;

class BookingController extends Controller
{
    public function showAllBooking()
    {
        $bookings = Booking::with('user', 'service')->get();

        $booking = $bookings->groupBy('status')->map(function ($group) {
            return $group->map(function ($booking) {
                return [
                    'id_booking' => $booking->id,
                    'user' => [
                        'id_user' => $booking->user->id,
                        'email' => $booking->user->email,
                        'name' => $booking->user->name,
                    ],
                    'service' => [
                        'id_service' => $booking->service->id,
                        'image' => $booking->service->image ? asset('storage/' . $booking->service->image) : null,
                        'title' => $booking->service->title,
                        'description' => $booking->service->description,
                        'location' => $booking->location,
                        'latitude' => $booking->service->location->latitude ?? null,
                        'longitude' => $booking->service->location->longitude ?? null,
                        'option' => $booking->option,
                        'date' => $booking->date,
                        'time' => $booking->time,
                        'note' => $booking->note,
                        'status' => $booking->status,
                    ],
                ];
            });
        });

        return response()->json([
            'status' => 'success',
            'message' => 'Booking retrieved successfully',
            'bookings' => $booking,
        ], 200);
    }
    public function showUserBooking()
    {
        $user = Auth::user();

        $bookings = Booking::with('service')
            ->where('user_id', $user->id)
            ->get()
            ->groupBy('status')
            ->map(function ($group) {
                return $group->map(function ($booking) {
                    return [
                        'id_booking' => $booking->id,
                        'service' => [
                            'id_service' => $booking->service->id,
                            'image' => $booking->service->image ? asset('storage/' . $booking->service->image) : null,
                            'title' => $booking->service->title,
                            'description' => $booking->service->description,
                            'location' => $booking->location,
                            'latitude' => $booking->service->location->latitude ?? null,
                            'longitude' => $booking->service->location->longitude ?? null,
                        ],
                        'option' => $booking->option,
                        'date' => $booking->date,
                        'time' => $booking->time,
                        'note' => $booking->note,
                        'status' => $booking->status,
                    ];
                });
            });

        return response()->json([
            'status' => 'success',
            'message' => 'Service retrieved successfully',
            'user' => [
                'id_user' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
            ],
            'services' => $bookings,
        ], 200);
    }
    public function showAssignedBooking()
    {
        $assignedUser = Auth::user();

        $assignedBookings = Booking::with('user', 'service')
            ->whereHas('service', function ($query) use ($assignedUser) {
                $query->where('user_id', $assignedUser->id);
            })
            ->get()
            ->groupBy('status')
            ->map(function ($group) {
                return $group->map(function ($booking) {
                    return [
                        'id_booking' => $booking->id,
                        'user' => [
                            'id_user' => $booking->user->id,
                            'email' => $booking->user->email,
                            'name' => $booking->user->name,
                        ],
                        'service' => [
                            'id_service' => $booking->service->id,
                            'image' => $booking->service->image ? asset('storage/' . $booking->service->image) : null,
                            'title' => $booking->service->title,
                            'description' => $booking->service->description,
                            'location' => $booking->location,
                            'latitude' => $booking->service->location->latitude ?? null,
                            'longitude' => $booking->service->location->longitude ?? null,
                            'option' => $booking->option,
                            'date' => $booking->date,
                            'time' => $booking->time,
                            'note' => $booking->note,
                            'status' => $booking->status,
                        ],
                    ];
                });
            });

        return response()->json([
            'status' => 'success',
            'message' => 'Assigned booking retrieved successfully',
            'bookings' => $assignedBookings,
        ], 200);
    }
    public function showDetailBooking($id)
    {
        $user = Auth::user();

        $booking = Booking::with(['service', 'user'])->findOrFail($id);

        if ($booking->user_id !== $user->id) {
            return response()->json([
                'status' => 'error',
                'message' => 'You are not authorized to view this booking.',
            ], 403);
        }

        return response()->json([
            'status' => 'success',
            'message' => 'Booking retrieved successfully',
            'id_booking' => $booking->id,
            'user' => [
                'id' => $booking->user->id,
                'name' => $booking->user->name,
                'email' => $booking->user->email,
            ],
            'service' => [
                'id_service' => $booking->service->id,
                'image' => $booking->service->image ? asset('storage/' . $booking->service->image) : null,
                'title' => $booking->service->title,
                'description' => $booking->service->description,
                'location' => $booking->location,
                'latitude' => $booking->service->location->latitude ?? null,
                'longitude' => $booking->service->location->longitude ?? null,
                'option' => $booking->option,
                'date' => $booking->date,
                'time' => $booking->time,
                'note' => $booking->note,
                'status' => $booking->status,
            ],
        ], 200);
    }
    public function bookService(Request $request, $id)
    {
        $user = Auth::user();
        $service = Service::with('schedule')->findOrFail($id);

        $availableOption = json_decode($service->option, true);
        $availableTime = json_decode($service->schedule->time, true);

        $scheduleDates = json_decode($service->schedule->date, true);
        $availableDate = collect($scheduleDates)->pluck('date')->toArray();

        $validated = $request->validate([
            'date' => 'required|date|in:' . implode(',', $availableDate),
            'time' => 'required|date_format:H:i|in:' . implode(',', $availableTime),
            'option' => 'required|string|in:' . implode(',', $availableOption),
        ]);

        $alreadyBooked = Booking::where('service_id', $service->id)
        ->where('user_id', $user->id)
        ->where('date', $validated['date'])
        ->where('time', $validated['time'])
        ->whereIn('status', ['Pending', 'Approved']) 
        ->exists();


        if ($alreadyBooked) {
            return response()->json([
                'status' => 'error',
                'message' => 'You have already booked this service at the selected date and time.',
            ], 400);
        }

        $otherBooked = Booking::where('service_id', $service->id)
        ->where('date', $validated['date'])
        ->where('time', $validated['time'])
        ->whereIn('status', ['Pending', 'Approved']) 
        ->exists();


        if ($otherBooked) {
            return response()->json([
                'status' => 'error',
                'message' => 'The service on this date and time has already been booked by someone else.',
            ], 400);
        }

        $booking = Booking::create([
            'service_id' => $service->id,
            'user_id' => $user->id,
            'option' => $validated['option'],
            'date' => $validated['date'],
            'time' => $validated['time'],
            'note' => $validated['note'] ?? null,
            'status' => 'Pending',
            'location' => $validated['option'] === 'Online'
                ? 'Waiting for video meeting URL'
                : $service->location->location,
        ]);

         // Notify the user about the booking confirmation 
         $booking->service->assigned->notify(new BookingMailNotif($booking));

        return response()->json([
            'status' => 'success',
            'message' => 'Service booked successfully, awaiting approval.',
            'user' => [
                'id_user' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
            ],
            'booking' => [
                'id_booking' => $booking->id,
                'option' => $booking->option,
                'date' => $booking->date,
                'time' => $booking->time,
                'note' => $booking->note,
                'location' => $booking->location,
                'latitude' => $booking->service->location->latitude ?? null,
                'longitude' => $booking->service->location->longitude ?? null,
                'status' => $booking->status,
                'service' => [
                    'id_service' => $service->id,
                    'title' => $service->title,
                ],
            ],
        ], 201);
    }
    public function confirm(Request $request, $id)
    {
        $request->validate([
            'status' => 'required|in:Approved,Declined',
            'note' => 'nullable|string|max:255',
        ]);

        $booking = Booking::with('service', 'user')->findOrFail($id);

        if (in_array($booking->status, ['Approved', 'Declined'])) {
            return response()->json([
                'status' => 'error',
                'message' => 'This booking status has already been finalized and cannot be changed.',
            ], 403);
        }

        $booking->status = $request->status;
        $booking->note = $request->note ?? null;

        // generate Jitsi meeting link if the booking is approved and the option is online
        if (
            $request->status === 'Approved' &&
            $booking->option === 'Online'
        ) {
            $slug = Str::slug($booking->service->title);
            $dateTimeSlug = Str::slug($booking->date . '-' . $booking->time);
            $roomName = "{$slug}-{$booking->user->id}-{$dateTimeSlug}";
            $booking->location = "https://meet.jit.si/{$roomName}";
        }

        $booking->save();

        // Notify the user about the booking confirmation 
        $booking->user->notify(new ConfirmedBookingMail($booking));

        return response()->json([
            'status' => 'success',
            'message' => 'Booking status updated successfully.',
            'booking' => [
                'id_booking' => $booking->id,
                'status' => $booking->status,
                'note' => $booking->note,
                'location' => $booking->location,
                'latitude' => $booking->service->location->latitude ?? null,
                'longitude' => $booking->service->location->longitude ?? null,
            ],
        ], 200);
    }
}
