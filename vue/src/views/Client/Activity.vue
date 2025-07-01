// Activity.vue
<script setup>
import { ref, onMounted, computed, watch } from 'vue'
import { useAuthStore } from '@/stores/auth'
import { useBookingStore } from '@/stores/booking'
import ActivityCard from '@/components/Client/card/ActivityCard.vue'
import PaginationPage from '@/components/Client/Pagination/PaginationPage.vue'
import ReviewModal from '@/components/Client/modals/ReviewModal.vue'

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
// Mengubah bookingExtraStatusData menjadi Map untuk mapping yang lebih efisien
const bookingExtraStatusData = ref(new Map())

// Load data on mount
onMounted(() => {
  bookingStore.fetchUserBookings()
  bookingStore.fetchUserReviews()
})

// Computed
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

const totalPages = computed(() =>
  Math.max(1, Math.ceil(filteredBookings.value.length / perPage))
)

const changePage = (page) => {
  if (page >= 1 && page <= totalPages.value) currentPage.value = page
}

const globalLoading = computed(() => bookingStore.loading)

// Review mapping - FUNGSI INI ADALAH KUNCI PERBAIKAN
const fetchAndProcessAllBookingExtraData = () => {
  const userReviews = bookingStore.userReviews
  const newStatusData = new Map()

  bookings.value.forEach((booking) => {
    let hasUserReviewed = false
    let review = null

    // Hanya proses booking yang statusnya 'Completed'
    if (booking.status === 'Completed' && booking.service?.id_service) {
      // Cari review yang cocok dengan service ID dari booking saat ini
      // Menggunakan find agar mengambil review pertama yang cocok (atau satu-satunya jika ada)
      review = userReviews.find(
        // Perbaikan di sini: Akses r.service.id sesuai struktur JSON review
        (r) => r.service?.id === booking.service.id_service
      )
      hasUserReviewed = !!review
    }

    // Console log untuk debugging, pastikan review yang ditemukan sesuai
    console.log(`📌 Booking ID ${booking.id_booking} — Review:`, review)

    newStatusData.set(booking.id_booking, { hasUserReviewed, review })
  })

  // Update nilai ref Map
  bookingExtraStatusData.value = newStatusData
}


// Watchers
// Panggil fetchAndProcessAllBookingExtraData saat bookings atau userReviews berubah
watch(bookings, fetchAndProcessAllBookingExtraData, { immediate: true }) // immediate: true untuk menjalankan di awal
watch(() => bookingStore.userReviews, fetchAndProcessAllBookingExtraData, { deep: true })
watch([selectedStatus, selectedDate, searchQuery], () => {
  currentPage.value = 1
})

// Aksi
const handleBookingStatusUpdated = async (bookingId) => {
  try {
    await bookingStore.completeBooking(bookingId)
    alert('Booking berhasil diselesaikan!')

    // Setelah booking diselesaikan, panggil ulang semua data
    // fetchUserBookings akan memperbarui `bookings`, dan watcher akan memicu `fetchAndProcessAllBookingExtraData`
    // fetchUserReviews juga harus dipanggil ulang untuk memastikan data review terbaru
    await bookingStore.fetchUserBookings()
    await bookingStore.fetchUserReviews()
    // fetchAndProcessAllBookingExtraData akan dipicu oleh watcher
  } catch (error) {
    alert('Gagal menyelesaikan booking: ' + (error.response?.data?.message || error.message))
  }
}


const openReviewModalFromCard = (serviceId) => {
  selectedServiceIdForReview.value = serviceId
  showReviewModal.value = true
}

const handleReviewSubmitted = async () => {
  alert('Review berhasil dikirim!')
  showReviewModal.value = false

  // Setelah review disubmit, panggil ulang semua data
  // Ini akan memastikan `bookings` dan `userReviews` diperbarui,
  // yang kemudian akan memicu `fetchAndProcessAllBookingExtraData` melalui watcher
  await bookingStore.fetchUserBookings()
  await bookingStore.fetchUserReviews()
}
</script>

<template>
  <div class="bg-gray-100 min-h-screen p-4">
    <div class="max-w-4xl mx-auto">
      <div class="mb-6 bg-white rounded-lg shadow p-6">
        <h1 class="text-3xl font-bold text-gray-800 mb-6">Your Booking History</h1>
        <div class="flex flex-wrap gap-4 text-sm">
          <div class="flex-grow">
            <input
              type="date"
              v-model="selectedDate"
              class="border px-3 py-2 rounded-lg w-full focus:ring-blue-500 focus:border-blue-500"
            />
          </div>
          <div class="flex-grow sm:flex-grow-0 sm:w-64">
            <input
              type="text"
              v-model="searchQuery"
              placeholder="Search title, option, note..."
              class="border px-3 py-2 rounded-lg w-full focus:ring-blue-500 focus:border-blue-500"
            />
          </div>
          <div class="flex flex-wrap gap-3 mt-4 sm:mt-0">
            <button
              v-for="status in ['All', 'Pending', 'Approved', 'Completed', 'Declined']"
              :key="status"
              :class="[
                'border px-4 py-2 rounded-lg font-medium transition duration-200',
                selectedStatus === status
                  ? 'bg-blue-600 text-white shadow'
                  : 'bg-white text-gray-700 hover:bg-gray-50',
              ]"
              @click="selectedStatus = status"
            >
              {{ status }} ({{ bookingCounts[status] || 0 }})
            </button>
          </div>
        </div>
      </div>

      <div>
        <div v-if="globalLoading" class="text-center py-10 text-gray-500 text-lg">
          <svg
            class="animate-spin h-8 w-8 text-blue-500 mx-auto mb-3"
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
          >
            <circle
              class="opacity-25"
              cx="12"
              cy="12"
              r="10"
              stroke="currentColor"
              stroke-width="4"
            ></circle>
            <path
              class="opacity-75"
              fill="currentColor"
              d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"
            />
          </svg>
          Loading booking activity...
        </div>

        <div
          v-else-if="filteredBookings.length === 0"
          class="bg-white rounded-lg shadow p-6 text-center text-gray-600"
        >
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