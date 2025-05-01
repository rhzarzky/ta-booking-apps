<template>
  <div class="p-8 bg-gray-100 min-h-screen">
    <div class="mb-6">
      <h1 class="text-2xl font-semibold">Activity</h1>
      <nav class="text-sm text-gray-500">
        <router-link to="/client/dashboard" class="pointer hover:underline">Dashboard</router-link>
        /
        <span class="text-indigo-600 capitalize">Activity</span>
      </nav>

      <div class="flex flex-wrap gap-4 text-sm mb-6">
        <select class="border px-3 py-2 rounded">
          <option>Last 7 days</option>
          <option>Last 30 days</option>
        </select>
        <input type="date" class="border px-3 py-2 rounded" />
        <button class="border px-3 py-2 rounded">All 24</button>
        <button class="border px-3 py-2 rounded">Approved 24</button>
        <button class="border px-3 py-2 rounded">Under Review 24</button>
        <button class="border px-3 py-2 rounded">Declined 24</button>
      </div>
    </div>

    <!-- Cards -->
    <div>
      <ActivityCard
        v-for="(item, index) in paginatedBookings"
        :key="index"
        :booking="item"
      />
    </div>

    <!-- Pagination -->
    <div class="flex justify-between items-center mt-6 text-sm text-gray-500">
      <p>Showing page {{ currentPage }} of {{ totalPages }}</p>
      <div class="flex items-center">
        <button
          :class="[
            'border-[0.5px] border-indigo-600 h-10 w-8 flex items-center justify-center rounded-tl rounded-bl',
            currentPage === 1 ? 'bg-transparent' : 'bg-white text-indigo-600',
          ]"
          @click="changePage(currentPage - 1)"
          :disabled="currentPage === 1"
        >
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-chevron-left" viewBox="0 0 16 16">
            <path fill-rule="evenodd" d="M11.354 1.646a.5.5 0 0 1 0 .708L5.707 8l5.647 5.646a.5.5 0 0 1-.708.708l-6-6a.5.5 0 0 1 0-.708l6-6a.5.5 0 0 1 .708 0" />
          </svg>
        </button>
        <button
          v-for="page in totalPages"
          :key="page"
          class="border-[0.5px] border-indigo-600 h-10 w-8 flex items-center justify-center"
          :class="{
            'bg-indigo-600 text-white': page === currentPage,
            'bg-white text-indigo-600': page !== currentPage,
          }"
          @click="changePage(page)"
        >
          {{ page }}
        </button>
        <button
          :class="[
            'border-[0.5px] border-indigo-600 h-10 w-8 flex items-center justify-center rounded-tr rounded-br',
            currentPage === totalPages ? 'bg-transparent' : 'bg-white text-indigo-600',
          ]"
          @click="changePage(currentPage + 1)"
          :disabled="currentPage === totalPages"
        >
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-chevron-right" viewBox="0 0 16 16">
            <path fill-rule="evenodd" d="M4.646 1.646a.5.5 0 0 1 .708 0l6 6a.5.5 0 0 1 0 .708l-6 6a.5.5 0 0 1-.708-.708L10.293 8 4.646 2.354a.5.5 0 0 1 0-.708" />
          </svg>
        </button>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, computed } from 'vue'
import ActivityCard from '@/components/Client/ActivityCard.vue'
import technicianImage from '@/assets/images/booking.jpg'

export default {
  name: 'Activity',
  components: {
    ActivityCard,
  },
  setup() {
    const bookings = ref([
      {
        title: 'Quality Workmanship Guaranteed',
        description:
          'Offering electrical services for your home, large city, and everything in between.',
        date: 'Mon, 23 January 2025',
        location: 'Zoom',
        duration: '60 Minute',
        status: 'Approved',
        note: '',
        image: technicianImage,
      },
    ])

    const currentPage = ref(1)
    const perPage = 5

    const totalPages = computed(() => {
      return Math.ceil(bookings.value.length / perPage)
    })

    const paginatedBookings = computed(() => {
      const start = (currentPage.value - 1) * perPage
      const end = start + perPage
      return bookings.value.slice(start, end)
    })

    function changePage(page) {
      if (page >= 1 && page <= totalPages.value) {
        currentPage.value = page
      }
    }

    return {
      bookings,
      currentPage,
      totalPages,
      paginatedBookings,
      changePage,
    }
  },
}
</script>
