<template>
  <div class="p-8 bg-gray-100 min-h-screen">
    <div class="flex justify-between items-center mb-6">
      <div>
        <h1 class="text-2xl font-semibold">Meetings</h1>
        <nav class="text-sm text-gray-500">
          <span class="hover:underline">Dashboard</span> / <span class="text-indigo-600">Meetings</span>
        </nav>
      </div>
      <div class="flex gap-2">
        <select class="border rounded px-3 py-1 text-sm">
          <option>Showing 9 content</option>
        </select>
        <select class="border rounded px-3 py-1 text-sm">
          <option>Newest</option>
        </select>
      </div>
    </div>

    <!-- Cards Grid -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
      <MeetingCard v-for="(item, i) in 9" :key="i" />
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
import MeetingCard from '@/components/Client/MeetingCard.vue'

export default {
  components: {
    MeetingCard,
  },
}
</script>
