<template>
  <div class="p-8 bg-gray-100 min-h-screen">
    <!-- Header -->
    <div class="mb-6">
      <h1 class="text-2xl font-semibold">Activity</h1>
      <nav class="text-sm text-gray-500">
        <router-link to="/client/dashboard" class="hover:underline">Dashboard</router-link>
        /
        <span class="text-indigo-600 capitalize">Activity</span>
      </nav>

      <!-- Filter -->
      <div class="flex flex-wrap gap-4 text-sm mb-6 mt-4">
        <input
          type="date"
          v-model="selectedDate"
          class="border px-3 py-2 rounded"
        />
        <button
          v-for="status in ['All', 'Approved', 'Pending', 'Declined']"
          :key="status"
          :class="[
            'border px-3 py-2 rounded',
            selectedStatus === status
              ? 'bg-indigo-600 text-white'
              : 'bg-white text-indigo-600'
          ]"
          @click="selectedStatus = status"
        >
          {{ status }} ({{ bookingCounts[status] || 0 }})
        </button>
      </div>
    </div>

    <!-- Cards -->
    <div>
      <ActivityCard
        v-for="(item, index) in paginatedBookings"
        :key="index"
        :booking="item"
      />
      <div v-if="loading" class="text-center py-6 text-gray-500">Loading...</div>
      <div v-if="!loading && filteredBookings.length === 0" class="text-center py-6 text-gray-500">
        No bookings available.
      </div>
    </div>

    <!-- Pagination: SELALU MUNCUL -->
    <PaginationPage
      :currentPage="currentPage"
      :totalPages="totalPages"
      @page-change="changePage"
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useBookingStore } from '@/stores/booking'
import ActivityCard from '@/components/Client/card/ActivityCard.vue'
import PaginationPage from '@/components/Client/Pagination/PaginationPage.vue'

const bookingStore = useBookingStore()
const currentPage = ref(1)
const perPage = 5

const selectedStatus = ref('All')
const selectedDate = ref('')

// Ambil data saat halaman dimuat
onMounted(() => {
  bookingStore.fetchUserBookings()
})

// Reset currentPage ke 1 saat filter berubah
watch([selectedStatus, selectedDate], () => {
  currentPage.value = 1
})

// Semua data booking
const bookings = computed(() => {
  return Object.values(bookingStore.bookingsByStatus).flat()
})

// Filter data berdasarkan status & tanggal
const filteredBookings = computed(() => {
  return bookings.value.filter((booking) => {
    const matchStatus = selectedStatus.value === 'All' || booking.status === selectedStatus.value
    const matchDate = !selectedDate.value || booking.date === selectedDate.value
    return matchStatus && matchDate
  })
})

// Hitung jumlah per status
const bookingCounts = computed(() => {
  const counts = {
    All: 0,
    Approved: 0,
    Pending: 0,
    Declined: 0,
  }

  bookings.value.forEach((booking) => {
    if (booking.status in counts) {
      counts[booking.status]++
    }
    counts.All++
  })

  return counts
})


// Pagination hasil filter
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


const loading = computed(() => bookingStore.loading)
</script>
