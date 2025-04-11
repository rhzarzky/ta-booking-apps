<template>
    <div class="bg-white rounded-lg shadow p-4">
      <img :src="technicianImage" alt="Technician" class="h-40 w-full object-cover rounded-lg mb-4" />
      <h2 class="text-sm font-semibold mb-1">Service Electric 24/7 Available</h2>
      <p class="text-xs text-gray-600 mb-2">
        Offering electrical services for your home, large city, and everything in between.
      </p>
      <div class="text-xs flex justify-between mb-1">
        <span class="bg-green-100 text-green-700 px-2 py-1 rounded">Available Now</span>
        <span class="bg-gray-100 text-gray-700 px-2 py-1 rounded">Schedule From</span>
      </div>
      <div class="text-xs text-gray-500 mb-4">
        3+ Ways to Meet <span class="ml-2">Fri 07 Feb, 2025</span>
      </div>
      <button
        @click="goToDetail"
        class="w-full bg-indigo-600 text-white text-sm py-2 rounded hover:bg-indigo-700"
      >
        Book Appointment
      </button>
    </div>
  </template>
  
  <script>
  import technicianImage from '@/assets/images/booking.jpg'
  
  export default {
    name: 'MeetingCard',
    data() {
      return {
        technicianImage,
      }
    },
    methods: {
      goToDetail() {
        this.$router.push({ name: 'DetailBooking' })
      },
    },
  }
  </script>
  