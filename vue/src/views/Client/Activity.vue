<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useBookingStore } from '@/stores/booking'
import ActivityCard from '@/components/Client/card/ActivityCard.vue'
import PaginationPage from '@/components/Client/Pagination/PaginationPage.vue'

// Store dan pagination
const bookingStore = useBookingStore()
const currentPage = ref(1)
const perPage = 5

// Filter states
const selectedStatus = ref('All')
const selectedDate = ref('')
const searchQuery = ref('')

// Ambil data booking saat komponen dimuat
onMounted(() => {
  bookingStore.fetchUserBookings()
})

// Reset currentPage ke 1 saat filter berubah
watch([selectedStatus, selectedDate], () => {
  currentPage.value = 1
})

// Reset currentPage ke 1 saat search berubah
watch(searchQuery, () => {
  currentPage.value = 1
})

// Semua data booking dari store
const bookings = computed(() => {
  return Object.values(bookingStore.bookingsByStatus)
    .flat()
    .sort((a, b) => {
      const dateTimeA = new Date(`${a.date}T${a.time}`);
      const dateTimeB = new Date(`${b.date}T${b.time}`);
      return dateTimeA - dateTimeB; 
    });
});

// Filter data berdasarkan status, tanggal, dan search
const filteredBookings = computed(() => {
  return bookings.value.filter((booking) => {
    const matchStatus = selectedStatus.value === 'All' || booking.status === selectedStatus.value
    const matchDate = !selectedDate.value || booking.date === selectedDate.value
    const matchSearch =
      !searchQuery.value ||
      booking.service?.title?.toLowerCase().includes(searchQuery.value.toLowerCase()) ||
      booking.service?.description?.toLowerCase().includes(searchQuery.value.toLowerCase()) || // Tambahkan pencarian deskripsi
      booking.option?.toLowerCase().includes(searchQuery.value.toLowerCase()) || // Tambahkan pencarian opsi
      booking.note?.toLowerCase().includes(searchQuery.value.toLowerCase()) // Tambahkan pencarian note

    return matchStatus && matchDate && matchSearch
  })
})

// Hitung total booking per status
const bookingCounts = computed(() => {
  const counts = {
    All: 0,
    Approved: 0,
    Pending: 0,
    Declined: 0,
    Completed: 0,
  }

  bookings.value.forEach((booking) => {
    if (booking.status in counts) {
      counts[booking.status]++
    }
    counts.All++
  })

  return counts
})

// Pagination
const paginatedBookings = computed(() => {
  const start = (currentPage.value - 1) * perPage
  const end = start + perPage
  return filteredBookings.value.slice(start, end)
})

const totalPages = computed(() => {
  return Math.max(1, Math.ceil(filteredBookings.value.length / perPage))
})

function changePage(page) {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
  }
}

// Loading state dari store
const loading = computed(() => bookingStore.loading)
</script>

<template>
  <div class="bg-gray-100 min-h-screen p-4">
    <div class="max-w-4xl mx-auto">
      <div class="mb-6 bg-white rounded-lg shadow p-6">
        <h1 class="text-3xl font-bold text-gray-800 mb-6">Your Booking Activity</h1>
        <div class="flex flex-wrap gap-4 text-sm">
          <div class="flex-grow">
            <label for="date-filter" class="sr-only">Filter by Date</label>
            <input
              id="date-filter"
              type="date"
              v-model="selectedDate"
              class="border px-3 py-2 rounded-lg w-full focus:ring-blue-500 focus:border-blue-500"
            />
          </div>

          <div class="flex-grow sm:flex-grow-0 sm:w-64">
            <label for="search-input" class="sr-only">Search Bookings</label>
            <input
              id="search-input"
              type="text"
              v-model="searchQuery"
              placeholder="Search by title, description, or notes..."
              class="border px-3 py-2 rounded-lg w-full focus:ring-blue-500 focus:border-blue-500"
            />
          </div>

          <div class="flex flex-wrap gap-3 mt-4 sm:mt-0">
            <button
              v-for="status in ['All', 'Pending', 'Approved', 'Declined', 'Completed']"
              :key="status"
              :class="[
                'border px-4 py-2 rounded-lg font-medium transition-colors duration-200 ease-in-out',
                selectedStatus === status
                  ? 'bg-blue-600 text-white shadow'
                  : 'bg-white text-gray-700 hover:bg-gray-50'
              ]"
              @click="selectedStatus = status"
            >
              {{ status }} ({{ bookingCounts[status] || 0 }})
            </button>
          </div>
        </div>
      </div>

      <div>
        <div v-if="loading" class="text-center py-10 text-gray-500 text-lg">
          <svg class="animate-spin h-8 w-8 text-blue-500 mx-auto mb-3" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
          </svg>
          Loading booking activity...
        </div>
        <div v-else-if="filteredBookings.length === 0" class="bg-white rounded-lg shadow p-6 text-center text-gray-600">
          <p class="text-lg">No booking activities available.</p>
          <p class="text-sm mt-2">Try customizing your filters or create a new booking!</p>
        </div>
        <ActivityCard
          v-else
          v-for="item in paginatedBookings"
          :key="item.id_booking"
          :booking="item"
          class="mb-4 transition-all duration-300 ease-in-out transform hover:scale-[1.01] hover:shadow-lg"
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
  </div>
</template>