<script setup>
import { ref, onMounted, computed, watch } from 'vue'
import { useAuthStore } from '@/stores/auth' 
import { useBookingStore } from '@/stores/booking' 
import ActivityCard from '@/components/Client/card/ActivityCard.vue' 
import PaginationPage from '@/components/Client/Pagination/PaginationPage.vue' 
import ReviewModal from '@/components/Client/modals/ReviewModal.vue' 
import AlertStatus from '@/components/Client/alert/AlertStatus.vue' 
import { useRoute } from 'vue-router'

// Store
const bookingStore = useBookingStore()
const authStore = useAuthStore()
const currentUser = computed(() => authStore.user)

// State
const currentPage = ref(1)
const perPage = 5
const selectedStatus = ref('All')
const selectedDate = ref('')
const searchQuery = ref('')
const showReviewModal = ref(false)
const selectedServiceIdForReview = ref(null)
const bookingExtraStatusData = ref(new Map())

// Alert State
const showAlert = ref(false)
const alertMessage = ref('')
const alertType = ref('success')

const route = useRoute()

function triggerAlert(message, type = 'success') {
  alertMessage.value = message
  alertType.value = type
  showAlert.value = true
}

onMounted(() => {
  const statusFromQuery = route.query.status
  const validStatuses = ['Pending', 'Approved', 'Completed', 'Declined']
  if (validStatuses.includes(statusFromQuery)) {
    selectedStatus.value = statusFromQuery
  }
}) 

// Load data
onMounted(() => {
  bookingStore.fetchUserBookings()
  bookingStore.fetchUserReviews()
})

// Computed Properties
const bookings = computed(() => {
  return Object.values(bookingStore.bookingsByStatus)
    .flat()
    .sort((a, b) => b.id_booking - a.id_booking)
})

const bookingCounts = computed(() => {
  const counts = { All: 0, Pending: 0, Approved: 0, Completed: 0, Declined: 0 }
  bookings.value.forEach((booking) => {
    if (booking.status in counts) counts[booking.status]++
    counts.All++
  })
  return counts
})

const filteredBookings = computed(() => {
  return bookings.value.filter((booking) => {
    const matchStatus = selectedStatus.value === 'All' || booking.status === selectedStatus.value
    const matchDate = !selectedDate.value || booking.date === selectedDate.value
    const matchSearch =
      !searchQuery.value ||
      booking.service?.title?.toLowerCase().includes(searchQuery.value.toLowerCase()) ||
      booking.service?.description?.toLowerCase().includes(searchQuery.value.toLowerCase()) ||
      booking.option?.toLowerCase().includes(searchQuery.value.toLowerCase()) ||
      booking.note?.toLowerCase().includes(searchQuery.value.toLowerCase())

    return matchStatus && matchDate && matchSearch
  })
})

const paginatedBookings = computed(() => {
  const start = (currentPage.value - 1) * perPage
  return filteredBookings.value.slice(start, start + perPage)
})

const totalPages = computed(() => Math.max(1, Math.ceil(filteredBookings.value.length / perPage)))

const globalLoading = computed(() => bookingStore.loading)

// Review mapping & data tambahan untuk ActivityCard
const fetchAndProcessAllBookingExtraData = () => {
  const userReviews = bookingStore.userReviews
  const newStatusData = new Map()

  bookings.value.forEach((booking) => {
    let hasUserReviewed = false
    let review = null

    const serviceId = booking.service?.id_service
    const bookingDate = booking.date 

    if (booking.status === 'Completed' && serviceId && bookingDate) {
      review = userReviews.find((r) => {
        const rawReviewDate = r.created_at?.split(' ')[0]
        if (rawReviewDate) {
            const [dd, mm, yyyy] = rawReviewDate.split('-')
            const reviewDateFormatted = `${yyyy}-${mm.padStart(2, '0')}-${dd.padStart(2, '0')}`
            
            return (
                r.service?.id === serviceId &&
                reviewDateFormatted === bookingDate
            )
        }
        return false;
      })
      hasUserReviewed = !!review
    }

    newStatusData.set(booking.id_booking, { hasUserReviewed, review })
  })

  bookingExtraStatusData.value = newStatusData
}

// Watchers
watch(bookings, fetchAndProcessAllBookingExtraData, { immediate: true })
watch(() => bookingStore.userReviews, fetchAndProcessAllBookingExtraData, { deep: true })
watch([selectedStatus, selectedDate, searchQuery], () => {
  currentPage.value = 1
})

// Actions
const changePage = (page) => {
  if (page >= 1 && page <= totalPages.value) currentPage.value = page
}

const handleBookingStatusUpdated = async (bookingId) => {
  try {
    await bookingStore.completeBooking(bookingId)
    triggerAlert('Booking berhasil diselesaikan!', 'success')
    await bookingStore.fetchUserBookings()
    await bookingStore.fetchUserReviews()
  } catch (error) {
    triggerAlert('Gagal menyelesaikan booking: ' + (error.response?.data?.message || error.message), 'error')
  }
}

const openReviewModalFromCard = (serviceId) => {
  selectedServiceIdForReview.value = serviceId
  showReviewModal.value = true
}

const handleReviewSubmitted = async () => {
  triggerAlert('Review berhasil dikirim!', 'success')
  showReviewModal.value = false
  await bookingStore.fetchUserBookings()
  await bookingStore.fetchUserReviews()
}

// Clear Filter Actions
const clearSearch = () => {
  searchQuery.value = '';
};

const clearDate = () => {
  selectedDate.value = '';
};

</script>

<template>
  <div class="bg-gray-100 min-h-screen p-4">
    <AlertStatus
      :message="alertMessage"
      :type="alertType"
      :isVisible="showAlert"
      @close="showAlert = false"
    />

    <div class="max-w-4xl mx-auto">
      <div class="mb-6 bg-white rounded-lg shadow p-6">
        <h1 class="text-3xl font-bold text-gray-800 mb-6">Your Booking History</h1>
        <div class="flex flex-col sm:flex-row sm:items-center gap-4 text-sm">
          <div class="relative flex-grow sm:flex-grow-0 sm:w-96 order-1 sm:order-1">
            <input
              type="text"
              v-model="searchQuery"
              placeholder="Search title, option, note..."
              class="border px-3 py-2 rounded-lg w-full pr-10 focus:ring-blue-500 focus:border-blue-500"
            />
            <button
              v-if="searchQuery"
              @click="clearSearch"
              class="absolute inset-y-0 right-0 pr-3 flex items-center text-gray-500 hover:text-gray-700"
              aria-label="Clear search"
            >
              <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
              </svg>
            </button>
          </div>

          <div class="relative flex-grow order-2 sm:order-2">
            <input
              type="date"
              v-model="selectedDate"
              class="border px-3 py-2 rounded-lg w-full focus:ring-blue-500 focus:border-blue-500"
            />
            <button
              v-if="selectedDate"
              @click="clearDate"
              class="absolute inset-y-0 right-0 pr-3 flex items-center text-gray-500 hover:text-gray-700"
              aria-label="Clear date"
            >
              <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
              </svg>
            </button>
          </div>

          <div class="order-3 sm:order-3">
            <select
              v-model="selectedStatus"
              class="border px-3 py-2 rounded-lg w-full sm:w-auto focus:ring-blue-500 focus:border-blue-500 bg-white pr-8"
            >
              <option value="All">All ({{ bookingCounts['All'] || 0 }})</option>
              <option value="Pending">Pending ({{ bookingCounts['Pending'] || 0 }})</option>
              <option value="Approved">Approved ({{ bookingCounts['Approved'] || 0 }})</option>
              <option value="Completed">Completed ({{ bookingCounts['Completed'] || 0 }})</option>
              <option value="Declined">Declined ({{ bookingCounts['Declined'] || 0 }})</option>
            </select>
          </div>
        </div>
      </div>

      <div>
        <div v-if="globalLoading" class="text-center py-10 text-gray-500 text-lg">
          <svg class="animate-spin h-8 w-8 text-blue-500 mx-auto mb-3" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"/>
          </svg>
          Loading booking history...
        </div>

        <div v-else-if="filteredBookings.length === 0" class="bg-white rounded-lg shadow p-6 text-center text-gray-600">
          <p class="text-lg">No booking activities available.</p>
          <p class="text-sm mt-2">Try changing filters or create a new booking.</p>
        </div>

        <ActivityCard
          v-else
          v-for="item in paginatedBookings"
          :key="item.id_booking"
          :booking="item"
          :extraStatusData="bookingExtraStatusData.get(item.id_booking)"
          @mark-completed="handleBookingStatusUpdated"
          @open-review-modal="openReviewModalFromCard"
          class="mb-4 transition duration-300 ease-in-out hover:scale-[1.01] hover:shadow-lg"
        />
      </div>

      <div v-if="totalPages > 1" class="mt-8">
        <PaginationPage
          :currentPage="currentPage"
          :totalPages="totalPages"
          @page-change="changePage"
        />
      </div>
    </div>

    <ReviewModal
      :show="showReviewModal"
      :serviceId="selectedServiceIdForReview"
      @close="showReviewModal = false"
      @review-submitted="handleReviewSubmitted"
    />
  </div>
</template>