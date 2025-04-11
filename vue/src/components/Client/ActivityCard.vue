<template>
    <div class="bg-white rounded-lg shadow p-4 mb-4">
      <div class="flex items-start gap-4">
        <img :src="booking.image" alt="Technician" class="w-28 h-28 rounded object-cover" />
        <div class="flex-1">
          <div class="flex justify-between items-start">
            <div>
              <h3 class="text-md font-semibold">{{ booking.title }}</h3>
              <p class="text-sm text-gray-500 mb-2">{{ booking.description }}</p>
              <div class="text-xs text-gray-600 space-y-1">
                <p><strong>Date:</strong> {{ booking.date }}</p>
                <p><strong>Location:</strong> {{ booking.location }}</p>
                <p><strong>Duration:</strong> {{ booking.duration }}</p>
              </div>
              <div v-if="booking.note" class="text-xs text-gray-500 mt-2">
                <strong>Note:</strong> {{ booking.note }}
              </div>
            </div>
            <span class="text-xs text-white bg-indigo-500 px-2 py-1 rounded">
              {{ booking.status }}
            </span>
          </div>
          <div class="mt-3">
            <router-link
              to="/client/detail-booking"
              class="text-sm text-indigo-600 hover:underline"
            >
              View detail booking
            </router-link>
          </div>
        </div>
      </div>
    </div>
  </template>
  
  <script>
  export default {
    name: 'ActivityCard',
    props: {
      booking: Object,
    },
  }
  </script>
  