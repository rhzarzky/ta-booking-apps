<?php

namespace App\Http\Controllers;

use App\Models\Service;
use App\Models\Schedule;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use Carbon\Carbon;

class ServiceController extends Controller
{
    public function showService()
    {
        $services = Service::with('schedule')
            ->select('id', 'image', 'title', 'description', 'option') 
            ->get()
            ->map(function ($service) {
                return [
                    'id' => $service->id,
                    'image' => $service->image ? asset('storage/' . $service->image) : null,
                    'title' => $service->title,
                    'description' => $service->description,
                    'option' => json_decode($service->option, true),
                    'time' => $service->schedule ? json_decode($service->schedule->time, true) : null,
                    'days' => $service->schedule ? json_decode($service->schedule->days, true) : null,
                    'date' => $service->schedule ? json_decode($service->schedule->date, true) : null,
                    'end_date' => $service->schedule ? $service->schedule->end_date : null,
                ];
            });

        return response()->json([
            'status' => 'success',
            'message' => 'Services retrieved successfully',
            'services' => $services,
        ], 200);
    }   
    public function storeService(Request $request)
    {
        $validated = $request->validate([
            'image' => 'nullable|image|mimes:jpg,jpeg,png,gif|max:2048',
            'title' => 'required|string|max:255',
            'description' => 'required|string|max:255',
            'option' => 'required|array',
            'option.*' => 'in:Offline,Online',
            'days' => 'required|array',
            'days.*' => 'in:Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday',
            'time' => 'required|array',
            'time.*' => 'required|date_format:H:i',
            'end_date' => 'nullable|date|after:today',
        ]);

        if ($request->hasFile('image')) {
            $imagePath = $request->file('image')->store('services', 'public');
            $validated['image'] = $imagePath;
        }

        // Convert array to JSON for storage
        $validated['option'] = json_encode($validated['option']);
        $validated['days'] = json_encode($validated['days']);
        $validated['time'] = json_encode($validated['time']);

        $service = Service::create($validated);

        // Auto-generate service date
        $days = $request->days;
        $endDate = $validated['end_date'] ? Carbon::parse($validated['end_date']) : Carbon::now()->addYear();
        $today = Carbon::now();
        $date = [];

        while ($today->lte($endDate)) {
            if (in_array($today->format('l'), $days)) {
                $date[] = [
                    'date' => $today->format('Y-m-d'),
                    'day' => $today->format('l'),
                ];
            }
            $today->addDay();
        }

        $schedule = Schedule::create([
            'service_id' => $service->id, 
            'days' => json_encode($days),
            'time' => json_encode($request->time),
            'end_date' => $request->end_date,
            'date' => json_encode($date),
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Service created successfully',
            'service' => [
                'id' => $service->id,
                'image' => $service->image ? asset('storage/' . $service->image) : null,
                'title' => $service->title,
                'description' => $service->description,
                'option' => json_decode($service->option),
                'days' => json_decode($schedule->days),
                'time' => json_decode($schedule->time),
                'date' => json_decode($schedule->date),
                'end_date' => $schedule->end_date,
            ],
        ], 201);
    }
    public function editService(Request $request, $id)
    {
        $validator = Validator::make($request->all(), [
            'image' => 'nullable|image|mimes:jpg,jpeg,png,gif|max:2048',
            'title' => 'sometimes|string|max:255',
            'description' => 'sometimes|string|max:255',
            'option' => 'sometimes|array',
            'option.*' => 'in:Offline,Online',
            'days' => 'sometimes|array',
            'days.*' => 'in:Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday',
            'end_date' => 'sometimes|date|after_or_equal:today', 
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            $service = Service::findOrFail($id);
            $validated = $validator->validated();

            if ($request->hasFile('image')) {
                $imagePath = $request->file('image')->store('services', 'public');
                $validated['image'] = $imagePath;
            }

            if (isset($validated['option'])) {
                $validated['option'] = json_encode($validated['option']);
            }

            if (isset($validated['days'])) {
                $validated['days'] = json_encode($validated['days']);
            }

            // Generate new date if 'days' or 'end_date' is updated
            if (isset($validated['days']) || isset($validated['end_date'])) {
                $days = isset($validated['days']) ? json_decode($validated['days'], true) : json_decode($service->days, true);
                $endDate = isset($validated['end_date']) ? Carbon::parse($validated['end_date']) : Carbon::parse($service->end_date);
                $today = Carbon::now();
                $date = [];

                while ($today->lte($endDate)) {
                    if (in_array($today->format('l'), $days)) {
                        $date[] = [
                            'date' => $today->format('Y-m-d'),
                            'day' => $today->format('l'),
                        ];
                    }
                    $today->addDay();
                }

                $validated['date'] = json_encode($date);
            }

            $service->update($validated);

            return response()->json([
                'status' => 'success',
                'message' => 'Service updated successfully',
                'service' => [
                    'id' => $service->id,
                    'image' => $service->image ? asset('storage/' . $service->image) : null,
                    'title' => $service->title,
                    'description' => $service->description,
                    'option' => json_decode($service->option, true),
                    'days' => json_decode($service->days, true),
                    'date' => json_decode($service->date, true),
                    'end_date' => $service->end_date,
                ],
            ], 200);
        } catch (ModelNotFoundException $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Service not found',
            ], 404);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'An error occurred while updating the service.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }
}
