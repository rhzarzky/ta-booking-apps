<script setup>
import fallbackImage from '@/assets/images/booking.jpg'
import { useRouter } from 'vue-router'
import { computed } from 'vue'

const router = useRouter()

const props = defineProps({
  booking: {
    type: Object,
    required: true,
  },
  extraStatusData: {
    type: Object,
    default: () => ({ hasUserReviewed: false }),
  },
})

console.log('🧩 ExtraStatusData received in ActivityCard:', props.extraStatusData)
const userReview = computed(() => {
  return props.extraStatusData?.review || null
})

const emit = defineEmits(['mark-completed', 'open-review-modal'])

const goToDetail = () => {
  router.push({ name: 'client-detail-booking', params: { id: props.booking.id_booking } })
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

const statusClass = computed(() => {
  switch (props.booking.status) {
    case 'Approved':
      return 'bg-blue-100 text-blue-800'
    case 'Completed':
      return 'bg-green-100 text-green-800'
    case 'Declined':
      return 'bg-red-100 text-red-800'
    case 'Pending':
      return 'bg-yellow-100 text-yellow-800'
    default:
      return 'bg-gray-100 text-gray-800'
  }
})

const handleMarkCompleted = () => {
  emit('mark-completed', props.booking.id_booking)
}

const handleOpenReviewModal = () => {
  emit('open-review-modal', props.booking.service?.id_service)
}
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
            <h2 class="text-xl font-semibold text-gray-800 mb-1">
              {{ booking.service?.title || '-' }}
            </h2>
            <p class="text-sm text-gray-600 mb-3">
              {{ booking.service?.description || '-' }}
            </p>
            <div class="text-sm text-gray-700 space-y-1">
              <p><strong>Date:</strong> {{ formatDate(booking.date) }}</p>
              <p><strong>Time:</strong> {{ formatTime(booking.time) }}</p>
              <p><strong>Option:</strong> {{ booking.option || '-' }}</p>
            </div>
            <div v-if="booking.note" class="text-xs text-gray-500 mt-2">
              <strong>Note:</strong> {{ booking.note }}
            </div>
          </div>
          <span class="text-xs px-2 py-1 rounded h-fit ml-2 whitespace-nowrap" :class="statusClass">
            {{ booking.status }}
          </span>
        </div>

        <div class="mt-3 flex flex-wrap items-center gap-4">
          <button @click="goToDetail" class="text-sm text-indigo-600 hover:underline">
            View detail booking
          </button>

          <button
            v-if="booking.status === 'Approved'"
            @click="handleMarkCompleted"
            class="text-sm bg-green-500 hover:bg-green-600 text-white py-1 px-3 rounded-lg transition-colors"
          >
            Mark as Completed
          </button>

          <!-- Tampilkan tombol jika belum review -->
          <button
            v-if="booking.status === 'Completed' && !extraStatusData.hasUserReviewed"
            @click="handleOpenReviewModal"
            class="text-sm bg-yellow-500 hover:bg-yellow-600 text-white py-1 px-3 rounded-lg transition-colors"
          >
            Berikan Review
          </button>

          <!-- Tampilkan hasil review jika sudah -->
          <div v-else-if="booking.status === 'Completed' && userReview" class="mt-2">
            <div class="flex items-center text-yellow-500 text-sm mb-1">
              <span v-for="n in 5" :key="n" class="mr-1">
                <svg
                  class="w-4 h-4"
                  fill="currentColor"
                  :class="n <= userReview.rating ? 'text-yellow-400' : 'text-gray-300'"
                  viewBox="0 0 20 20"
                >
                  <path
                    d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.538 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.783.57-1.838-.197-1.538-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.92 8.72c-.783-.57-.381-1.81.588-1.81h3.462a1 1 0 00.95-.69l1.07-3.292z"
                  />
                </svg>
              </span>
            </div>
            <p class="text-sm text-gray-700">{{ userReview.comment }}</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
