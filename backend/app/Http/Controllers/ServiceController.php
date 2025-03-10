<?php

namespace App\Http\Controllers;

use App\Models\Service;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use Carbon\Carbon;

class ServiceController extends Controller
{
    public function showService()
    {
        $services = Service::select('id', 'image', 'title', 'description', 'option', 'days', 'date', 'end_date')
            ->get()
            ->map(function ($service) {
                return [
                    'id' => $service->id,
                    'image' => $service->image ? asset('storage/' . $service->image) : null,
                    'title' => $service->title,
                    'description' => $service->description,
                    'option' => json_decode($service->option, true),
                    'days' => is_string($service->days) ? json_decode($service->days) : $service->days,
                    'date' => json_decode($service->date, true),
                    'end_date' => $service->end_date,
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
            'end_date' => 'nullable|date|after:today',
        ]);

        if ($request->hasFile('image')) {
            $imagePath = $request->file('image')->store('services', 'public');
            $validated['image'] = $imagePath;
        }

        $validated['option'] = json_encode($validated['option']);
        $validated['days'] = json_encode($validated['days']); 

        // Auto-generate service date
        $days = $request->days;
        $endDate = isset($validated['end_date']) ? Carbon::parse($validated['end_date']) : Carbon::now()->addYear(); // Default: 1 year ahead
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

        $service = Service::create($validated);

        return response()->json([
            'status' => 'success',
            'message' => 'Service created successfully',
            'service' => [
                'id' => $service->id,
                'image' => $service->image ? asset('storage/' . $service->image) : null,
                'title' => $service->title,
                'description' => $service->description,
                'option' => json_decode($service->option),
                'days' => json_decode($service->days),
                'date' => json_decode($service->date),
                'end_date' => $service->end_date,
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
