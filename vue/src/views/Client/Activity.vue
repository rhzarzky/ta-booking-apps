<template>
  <div class="p-8 bg-gray-100 min-h-screen">
    <div class="mb-6">
      <h1 class="text-2xl font-semibold">Activity</h1>
      <nav class="text-sm text-gray-500 mb-4">
        <span class="hover:underline">Dashboard</span> / 
        <span class="text-indigo-600">Activity</span>
      </nav>

      <div class="flex flex-wrap gap-4 text-sm mb-6">
        <select class="border px-3 py-2 rounded">
          <option>Last 7 days</option>
          <option>Last 30 days</option>
        </select>
        <input type="date" class="border px-3 py-2 rounded" />
        <input type="date" class="border px-3 py-2 rounded" />
        <button class="border px-3 py-2 rounded">All 24</button>
        <button class="border px-3 py-2 rounded">Approved 24</button>
        <button class="border px-3 py-2 rounded">Under Review 24</button>
        <button class="border px-3 py-2 rounded">Declined 24</button>
      </div>
    </div>

    <div>
      <ActivityCard
        v-for="(item, index) in bookings"
        :key="index"
        :booking="item"
      />
    </div>

    <!-- Pagination -->
    <div class="flex justify-between items-center mt-6 text-sm text-gray-500">
      <p>Showing page 1 of 8</p>
      <div class="flex gap-2 items-center">
        <button class="px-2 border rounded">&lt;</button>
        <button class="px-2 border rounded bg-indigo-600 text-white">1</button>
        <button class="px-2 border rounded">2</button>
        <button class="px-2 border rounded">3</button>
        <button class="px-2 border rounded">4</button>
        <button class="px-2 border rounded">&gt;</button>
      </div>
    </div>
  </div>
</template>

<script>
import ActivityCard from '@/components/Client/ActivityCard.vue'
import technicianImage from '@/assets/images/booking.jpg'

export default {
  name: 'Activity',
  components: {
    ActivityCard,
  },
  data() {
    return {
      bookings: [
        {
          title: 'Quality Workmanship Guaranteed',
          description: 'Offering electrical services for your home, large city, and everything in between.',
          date: 'Mon, 23 January 2025',
          location: 'Zoom',
          duration: '60 Minute',
          status: 'Approved',
          note: '',
          image: technicianImage,
        },
        // Tambah data lainnya jika perlu
      ],
    }
  },
}
</script>
