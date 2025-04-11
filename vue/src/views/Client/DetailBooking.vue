<template>
    <div class="p-8 bg-gray-100 min-h-screen">
      <!-- Breadcrumb -->
      <nav class="text-sm text-gray-500 mb-4">
        <span class="hover:underline cursor-pointer">Dashboard</span> /
        <span class="hover:underline cursor-pointer">Activity</span> /
        <span class="text-indigo-600">Detail Booking</span>
      </nav>
  
      <!-- Card -->
      <div class="bg-white rounded-xl overflow-hidden shadow-md">
        <img
          src="@/assets/images/booking.jpg"
          alt="Electric service"
          class="w-full h-64 object-cover"
        />
  
        <div class="p-6">
          <!-- Title -->
          <h2 class="text-2xl font-bold mb-1">Service Electric 24/7 Available</h2>
          <p class="text-gray-600 mb-4">
            Offering electrical services for your home, large city, and everything in between.
          </p>
  
          <!-- Schedule Section -->
          <div class="mb-4">
            <h3 class="font-semibold mb-1">Schedule</h3>
            <div class="flex items-center gap-4 bg-gray-100 p-3 rounded-md">
              <div>
                <label class="text-sm text-gray-600">Time & Date</label><br />
                <select class="border rounded px-3 py-1 text-sm mr-2">
                  <option>07:00 - 08:00 AM</option>
                </select>
                <input type="date" value="2025-02-07" class="border rounded px-3 py-1 text-sm" />
              </div>
            </div>
          </div>
  
          <!-- Location Options -->
          <div class="mb-4">
            <h3 class="font-semibold mb-1">Location</h3>
            <div class="flex flex-wrap gap-3 bg-gray-100 p-3 rounded-md">
              <button class="border px-3 py-1 rounded hover:bg-gray-200">📍 In-person meeting</button>
              <button class="border px-3 py-1 rounded hover:bg-gray-200">📺 Google Meet</button>
              <button class="border px-3 py-1 rounded hover:bg-gray-200">💻 Zoom</button>
            </div>
          </div>
  
          <!-- Note -->
          <div class="mb-4">
            <label class="block mb-1 font-medium">Note :</label>
            <textarea
              rows="4"
              placeholder="Add any additional notes..."
              class="w-full border rounded px-3 py-2"
            ></textarea>
          </div>
  
          <!-- Submit Button -->
          <div class="text-right">
            <button class="bg-indigo-600 text-white px-4 py-2 rounded hover:bg-indigo-700">
              Confirm Booking
            </button>
          </div>
        </div>
      </div>
    </div>
  </template>
  