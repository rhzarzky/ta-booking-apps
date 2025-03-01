<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Booking;
use Illuminate\Support\Facades\Auth;
use App\Models\Service;

class BookingController extends Controller
{
    public function bookService(Request $request, $id) 
    {
        $user = Auth::user();

        $service = Service::findOrFail($id);

        if (Booking::where('service_id', $service->id)->where('user_id', $user->id)->exists()) {
            return response()->json([
                'status' => 'error',
                'message' => 'You have already booked this service.',
            ], 400);
        }

        $booking = Booking::create([
            'service_id' => $service->id,  
            'user_id' => $user->id,        
            'status' => 'pending',         
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Service booked successfully, awaiting approval.',
            'booking' => [
                'id' => $booking->id,
                'service' => [
                    'id' => $service->id,
                    'title' => $service->title,
                    'description' => $service->description,
                    'option' => $service->option,
                    'start_date' => $service->start_date,
                ],
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                ],
                'status' => $booking->status,
            ],
        ], 201);
    }
}
