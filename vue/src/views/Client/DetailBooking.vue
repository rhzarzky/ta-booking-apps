<script setup>
import { onMounted, ref, computed } from 'vue'
import { useRoute } from 'vue-router'
import { bookingApi } from '@/api/booking-api'

const route = useRoute()
const booking = ref(null)

onMounted(async () => {
  try {
    const result = await bookingApi.getBookingDetail(route.params.id)
    booking.value = result
  } catch (error) {
    console.error('Failed to load booking detail:', error)
  }
})

const formattedDate = computed(() => {
  if (!booking.value) return ''
  const date = new Date(booking.value.service.date)
  return date.toLocaleDateString('en-GB', {
    day: 'numeric',
    month: 'short',
    year: 'numeric',
  })
})

const statusClass = computed(() => {
  if (!booking.value) return ''
  const status = booking.value.service.status
  switch (status) {
    case 'Approved':
      return 'bg-green-100 text-green-700 px-2 py-1 rounded'
    case 'Pending':
      return 'bg-primary-100 text-primary-700 px-2 py-1 rounded'
    default:
      return 'bg-red-100 text-red-700 px-2 py-1 rounded'
  }
})

// Google Calendar Link Generator
const generateGoogleCalendarUrl = computed(() => {
  if (!booking.value) return '#'

  const title = encodeURIComponent(booking.value.service.title)
  const details = encodeURIComponent(booking.value.service.description || '')
  const location = encodeURIComponent(booking.value.service.location || '')

  const startDate = new Date(`${booking.value.service.date}T${booking.value.service.time}`)
  const endDate = new Date(startDate.getTime() + 60 * 60 * 1000) // +1 jam

  const formatDate = (date) => {
    return date.toISOString().replace(/-|:|\.\d\d\d/g, '')
  }

  const dates = `${formatDate(startDate)}/${formatDate(endDate)}`
  return `https://www.google.com/calendar/render?action=TEMPLATE&text=${title}&details=${details}&location=${location}&dates=${dates}`
})
</script>

<template>
  <div class="p-2 bg-gray-100 min-h-screen">
    <div v-if="booking" class="bg-white rounded-xl overflow-hidden shadow-md">
      <div class="w-full h-64 bg-gray-200 flex items-center justify-center text-gray-400 text-xl">
        <template v-if="booking.service.image">
          <img :src="booking.service.image" class="w-full h-full object-cover" />
        </template>
        <template v-else>
          No Image Available
        </template>
      </div>

      <div class="p-6">
        <h2 class="text-2xl font-bold mb-1">{{ booking.service.title }}</h2>
        <p class="text-gray-600 mb-4">{{ booking.service.description }}</p>

        <div class="flex items-center justify-between mb-4 text-sm">
          <span :class="statusClass">{{ booking.service.status }}</span>
          <span class="text-gray-500">{{ formattedDate }}</span>
        </div>

        <div class="mb-4">
          <h3 class="font-semibold mb-1">Schedule</h3>
          <div class="bg-gray-100 p-3 rounded-md">
            <p class="text-sm text-gray-700">
              {{ booking.service.time }} WIB, {{ formattedDate }}
            </p>
          </div>
        </div>

        <div class="mb-4">
          <h3 class="font-semibold mb-1">Location</h3>
          <div class="bg-gray-100 p-3 rounded-md break-all">
            <a
              :href="booking.service.location"
              target="_blank"
              class="text-indigo-600 hover:underline"
            >
              {{ booking.service.location }}
            </a>
          </div>
        </div>

        <div class="mb-4">
          <h3 class="font-semibold mb-1">Option</h3>
          <div class="bg-gray-100 p-3 rounded-md">
            <p class="text-sm">{{ booking.service.option }}</p>
          </div>
        </div>

        <div class="mb-4">
          <h3 class="font-semibold mb-1">Note</h3>
          <div class="bg-gray-100 p-3 rounded-md">
            <p class="text-sm">{{ booking.service.note }}</p>
          </div>
        </div>

        <!-- Tombol Tambahkan ke Kalender -->
        <div class="mb-4 text-center">
          <a
            :href="generateGoogleCalendarUrl"
            target="_blank"
            class="inline-block bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700 transition"
          >
            Tambahkan ke Google Calendar
          </a>
        </div>
      </div>
    </div>

    <div v-else class="text-center text-gray-500">Loading booking data...</div>
  </div>
</template>
