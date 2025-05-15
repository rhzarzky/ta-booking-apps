<template>
  <div class="bg-white rounded-lg shadow p-4 mb-4">
    <div class="flex items-start gap-4">
      <img
        :src="booking.image || fallbackImage"
        alt="Booking"
        class="w-28 h-28 rounded object-cover"
      />
      <div class="flex-1">
        <div class="flex justify-between items-start">
          <div class="w-full">
            <!-- Judul dan Deskripsi -->
            <h2 class="text-xl font-semibold text-gray-800 mb-1">
              {{ booking.service?.title || '-' }}
            </h2>
            <p class="text-sm text-gray-600 mb-3">
              {{ booking.service?.description || '-' }}
            </p>

            <!-- Informasi Tanggal, Waktu, Lokasi -->
            <div class="text-sm text-gray-700 space-y-1">
              <p><strong>Date:</strong> {{ formatDate(booking.date) }}</p>
              <p><strong>Time:</strong> {{ formatTime(booking.time) }}</p>
              <p><strong>Option:</strong> {{ booking.option || '-' }}</p>
            </div>

            <!-- Note (Jika ada) -->
            <div v-if="booking.note" class="text-xs text-gray-500 mt-2">
              <strong>Note:</strong> {{ booking.note }}
            </div>
          </div>
          <span
            class="text-xs text-white bg-indigo-500 px-2 py-1 rounded h-fit ml-2 whitespace-nowrap"
          >
            {{ booking.status }}
          </span>
        </div>

        <!-- Tombol -->
        <div class="mt-3">
          <button @click="goToDetail" class="text-sm text-indigo-600 hover:underline">
            View detail booking
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import fallbackImage from '@/assets/images/booking.jpg'
import { useRouter } from 'vue-router'
import { computed } from 'vue'

const props = defineProps({
  booking: Object,
})

const router = useRouter()

const goToDetail = () => {
  router.push({
    name: 'client-detail-booking',
    params: {
      id: props.booking.id_booking
    }
  })
}


const formatDate = (dateStr) => {
  const options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' }
  return new Date(dateStr).toLocaleDateString(undefined, options)
}

const formatTime = (timeStr) => {
  if (!timeStr) return '-'
  const [hour, minute] = timeStr.split(':')
  return `${hour}:${minute}`
}



</script>
