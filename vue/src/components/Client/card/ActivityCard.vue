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

// 🎯 Dynamic status class berdasarkan booking.status
const statusClass = computed(() => {
  const status = (props.booking?.status || '').toLowerCase();
  switch (status) {
    case 'approved':
      return 'bg-purple-100 text-purple-700';
    case 'pending':
      return 'bg-lime-100 text-lime-700';
    case 'declined':
      return 'bg-red-100 text-red-700';
    case 'completed':
      return 'bg-blue-100 text-blue-700';
    default:
      return 'bg-gray-100 text-gray-700';
  }
})
</script>

<template>
  <div class="bg-white rounded-lg shadow p-4 mb-4">
    <div class="flex items-start gap-4">
      <img
        :src="booking.service?.image || fallbackImage"
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

          <!-- Dynamic Badge -->
          <span
            class="text-xs px-2 py-1 rounded h-fit ml-2 whitespace-nowrap"
            :class="statusClass"
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
