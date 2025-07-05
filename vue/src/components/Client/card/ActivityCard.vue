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
  // Pastikan dateStr tidak null/undefined sebelum membuat objek Date
  if (!dateStr) return '-';
  const options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' }
  // Menambahkan penanganan error untuk tanggal yang tidak valid
  try {
    const date = new Date(dateStr);
    return date.toLocaleDateString('id-ID', options); 
  } catch (e) {
    console.error("Invalid date string:", dateStr, e);
    return '-';
  }
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

// Computed untuk Progress Bar
const progressPercentage = computed(() => {
  const bookingDate = new Date(props.booking.date);
  const now = new Date();
  
  if (props.booking.status === 'Completed' || props.booking.status === 'Declined') {
    return 100; // Sudah selesai atau ditolak
  }
  
  // Jika tanggal booking sudah lewat atau hari ini
  if (bookingDate <= now) {
    return 100; 
  }


  const oneDay = 1000 * 60 * 60 * 24;
  const daysDiff = Math.max(0, (bookingDate.getTime() - now.getTime()) / oneDay);
  

  const maxDaysForProgress = 30;
  
  const percentage = 100 - (daysDiff / maxDaysForProgress) * 100;
  
  return Math.max(0, Math.min(100, percentage)); // Pastikan antara 0-100
});


// Computed untuk Indikator Lokasi
const locationIcon = computed(() => {
  if (props.booking.option === 'Online') {
    return `<svg class="w-4 h-4 mr-1 inline-block text-blue-500" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14m-5 3H7a2 2 0 01-2-2V7a2 2 0 012-2h3v12z"></path></svg>`;
  } else {
    return `<svg class="w-4 h-4 mr-1 inline-block text-blue-500" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a2 2 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"></path><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"></path></svg>`;
  }
});


const handleMarkCompleted = () => {
  emit('mark-completed', props.booking.id_booking)
}

const handleOpenReviewModal = () => {
  emit('open-review-modal', props.booking.service?.id_service)
}
</script>

<template>
  <div class="bg-white rounded-lg shadow-md p-4 mb-4 transition-shadow hover:shadow-lg cursor-pointer" @click="goToDetail">
    <div class="flex flex-col sm:flex-row items-start sm:items-center gap-4">
      <div class="flex-shrink-0 w-full sm:w-28 h-40 sm:h-28 overflow-hidden rounded-lg">
        <img
          :src="booking.service?.image || fallbackImage"
          :alt="booking.service?.title || 'Booking Service'"
          class="w-full h-full object-cover transition-transform duration-300 hover:scale-105"
        />
      </div>
      
      <div class="flex-1 w-full">
        <div class="flex flex-col sm:flex-row sm:justify-between sm:items-start mb-2">
          <div class="flex-1">
            <h2 class="text-xl font-semibold text-gray-800 mb-1 leading-tight sm:pr-4">
              {{ booking.service?.title || 'Layanan Tidak Diketahui' }}
            </h2>
            <p class="text-sm text-gray-600 line-clamp-2 mb-2">
              {{ booking.service?.description || 'Deskripsi tidak tersedia.' }}
            </p>
          </div>
          <span class="text-xs px-2.5 py-1.5 rounded-full h-fit mt-2 sm:mt-0 sm:ml-2 whitespace-nowrap font-medium" :class="statusClass">
            {{ booking.status }}
          </span>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-x-6 gap-y-2 text-sm text-gray-700 mb-3">
          <p class="flex items-center">
            <svg class="w-4 h-4 mr-1 text-gray-500" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg"><path fill-rule="evenodd" d="M6 2a1 1 0 00-1 1v1H4a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V6a2 2 0 00-2-2h-1V3a1 1 0 10-2 0v1H7V3a1 1 0 00-1-1zm0 5a1 1 0 000 2h8a1 1 0 100-2H6z" clip-rule="evenodd"></path></svg>
            <strong class="mr-1">Date:</strong> {{ formatDate(booking.date) }}
          </p>
          <p class="flex items-center">
            <svg class="w-4 h-4 mr-1 text-gray-500" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg"><path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-12a1 1 0 10-2 0v4a1 1 0 00.293.707l3 3a1 1 0 001.414-1.414L11 9.586V6z" clip-rule="evenodd"></path></svg>
            <strong class="mr-1">Time:</strong> {{ formatTime(booking.time) }}
          </p>
          <p class="flex items-center">
            <strong class="mr-1">Option:</strong> 
            <span v-html="locationIcon"></span>
            {{ booking.option || '-' }}
          </p>
        </div>
        <div v-if="booking.note" class="text-xs text-gray-500 mt-2 mb-3">
          <strong class="text-gray-700">Note:</strong> {{ booking.note }}
        </div>


        <div class="mt-3 flex flex-col sm:flex-row items-stretch sm:items-center gap-3">
          <button @click.stop="goToDetail" class="text-sm text-indigo-600 hover:underline flex items-center justify-center py-2 px-4 rounded-lg border border-indigo-200 hover:bg-indigo-50 transition-colors">
            <svg class="w-4 h-4 mr-1.5" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"></path>
            </svg>
            View Detail Booking
          </button>

          <button
            v-if="booking.status === 'Approved'"
            @click.stop="handleMarkCompleted"
            class="text-sm bg-green-600 hover:bg-green-700 text-white py-2 px-4 rounded-lg transition-colors flex items-center justify-center shadow-sm hover:shadow-md"
          >
            <svg class="w-4 h-4 mr-1.5" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
            </svg>
            Mark as Completed
          </button>

          <button
            v-if="booking.status === 'Completed' && !extraStatusData.hasUserReviewed"
            @click.stop="handleOpenReviewModal"
            class="text-sm bg-yellow-600 hover:bg-yellow-700 text-white py-2 px-4 rounded-lg transition-colors flex items-center justify-center shadow-sm hover:shadow-md"
          >
            <svg class="w-4 h-4 mr-1.5" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg">
                <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.538 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.783.57-1.838-.197-1.538-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.92 8.72c-.783-.57-.381-1.81.588-1.81h3.462a1 1 0 00.95-.69l1.07-3.292z"></path>
            </svg>
            Berikan Review
          </button>

          <div v-else-if="booking.status === 'Completed' && userReview" class="mt-2 text-sm">
            <div class="flex items-center text-yellow-500 mb-1">
              <span v-for="n in 5" :key="n" class="mr-0.5">
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
              <span class="text-gray-700 ml-1 font-medium">{{ userReview.rating }}/5</span>
            </div>
            <p class="text-gray-700 text-sm italic">{{ userReview.comment }}</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
/* Tambahan kecil untuk line-clamp jika teks deskripsi terlalu panjang */
.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  text-overflow: ellipsis;
}
</style>