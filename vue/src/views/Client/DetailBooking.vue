<template>
  <div class="p-8 bg-gray-100 min-h-screen">
    <!-- Breadcrumb -->
    <nav class="text-sm text-gray-500">
        <router-link to="/client/dashboard" class="pointer hover:underline">Dashboard</router-link>
        /
        <router-link to="/client/activity" class="pointer hover:underline">Activity</router-link>
        /
        <span class="text-indigo-600 capitalize">Detail Booking</span>
      </nav>

    <!-- Card -->
    <div class="bg-white rounded-xl overflow-hidden shadow-md">
      <img :src="image" alt="Booking image" class="w-full h-64 object-cover" />

      <div class="p-6">
        <!-- Title -->
        <h2 class="text-2xl font-bold mb-1">{{ title }}</h2>
        <p class="text-gray-600 mb-4">{{ description }}</p>

        <!-- Status & Date -->
        <div class="flex items-center justify-between mb-4 text-sm">
          <span :class="statusClass">{{ status }}</span>
          <span class="text-gray-500">{{ date }}</span>
        </div>

        <!-- Schedule Section -->
        <div class="mb-4">
          <h3 class="font-semibold mb-1">Schedule</h3>
          <div class="flex items-center gap-4 bg-gray-100 p-3 rounded-md">
            <div>
              <label class="text-sm text-gray-600">Time & Date</label><br />
              <div class="flex items-center">

                <select class="border rounded px-3 py-1 text-sm mr-2">
                  <option>07:00 - 08:00 AM</option>
                </select>
                <span class="text-sm text-gray-700 mt-1 flex bg-white px-2 py-1 items-center justify-center">
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    width="16"
                    height="16"
                    fill="currentColor"
                    class="bi bi-calendar mr-2"
                    viewBox="0 0 16 16"
                  >
                    <path
                      d="M3.5 0a.5.5 0 0 1 .5.5V1h8V.5a.5.5 0 0 1 1 0V1h1a2 2 0 0 1 2 2v11a2 2 0 0 1-2 2H2a2 2 0 0 1-2-2V3a2 2 0 0 1 2-2h1V.5a.5.5 0 0 1 .5-.5M1 4v10a1 1 0 0 0 1 1h12a1 1 0 0 0 1-1V4z"
                    />
                  </svg>
                  <span>{{ scheduleDate }}</span>
                </span>
              </div>
            </div>
          </div>
        </div>

        <!-- Location Options -->
        <div class="mb-4">
          <h3 class="font-semibold mb-1">Location</h3>
          <div class="flex flex-wrap gap-3 bg-gray-100 p-3 rounded-md">
            <button
              class="border px-3 py-1 rounded hover:bg-gray-200 flex items-center justify-center"
            >
              <svg
                xmlns="http://www.w3.org/2000/svg"
                width="16"
                height="16"
                fill="currentColor"
                class="bi bi-geo-alt mr-2"
                viewBox="0 0 16 16"
              >
                <path
                  d="M12.166 8.94c-.524 1.062-1.234 2.12-1.96 3.07A32 32 0 0 1 8 14.58a32 32 0 0 1-2.206-2.57c-.726-.95-1.436-2.008-1.96-3.07C3.304 7.867 3 6.862 3 6a5 5 0 0 1 10 0c0 .862-.305 1.867-.834 2.94M8 16s6-5.686 6-10A6 6 0 0 0 2 6c0 4.314 6 10 6 10"
                />
                <path d="M8 8a2 2 0 1 1 0-4 2 2 0 0 1 0 4m0 1a3 3 0 1 0 0-6 3 3 0 0 0 0 6" />
              </svg>
              <span> In-person meeting</span>
            </button>
            <button class="border px-3 py-1 rounded hover:bg-gray-200">📺 Google Meet</button>
            <button
              class="border px-3 py-1 rounded hover:bg-gray-200 flex items-center justify-center"
            >
              <svg
                xmlns="http://www.w3.org/2000/svg"
                width="16"
                height="16"
                fill="currentColor"
                class="bi bi-camera-video mr-2"
                viewBox="0 0 16 16"
              >
                <path
                  fill-rule="evenodd"
                  d="M0 5a2 2 0 0 1 2-2h7.5a2 2 0 0 1 1.983 1.738l3.11-1.382A1 1 0 0 1 16 4.269v7.462a1 1 0 0 1-1.406.913l-3.111-1.382A2 2 0 0 1 9.5 13H2a2 2 0 0 1-2-2zm11.5 5.175 3.5 1.556V4.269l-3.5 1.556zM2 4a1 1 0 0 0-1 1v6a1 1 0 0 0 1 1h7.5a1 1 0 0 0 1-1V5a1 1 0 0 0-1-1z"
                />
              </svg>
              Zoom
            </button>
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

<script setup>
import { computed } from 'vue'
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'

const route = useRoute()

const title = route.query.title || 'Default Title'
const description = route.query.description || 'Default description'
const status = route.query.status || 'Available Now'
const date = route.query.date || '2025-02-07'
const image = route.query.image || 'https://via.placeholder.com/640x360'

// Komputasi kelas status
const statusClass = computed(() => {
  return status === 'Available Now'
    ? 'bg-green-100 text-green-700 px-2 py-1 rounded'
    : 'bg-gray-100 text-gray-700 px-2 py-1 rounded'
})
const scheduleDate = ref('')

onMounted(() => {
  if (route.query.date) {
    const date = new Date(route.query.date)
    const options = { day: 'numeric', month: 'short', year: 'numeric' }
    scheduleDate.value = date.toLocaleDateString('en-GB', options)
  }
})
</script>
