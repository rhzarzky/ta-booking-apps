<template>
  <div class="p-8 bg-gray-100 min-h-screen">
    <div class="flex justify-between items-center mb-6">
      <div>
        <h1 class="text-2xl font-semibold">Meetings</h1>
        <nav class="text-sm text-gray-500">
          <router-link to="/client/dashboard" class="pointer hover:underline">Dashboard</router-link> /
          <span class="text-indigo-600 capitalize">Meeting</span>
        </nav>
      </div>
      <div class="flex gap-2">
        <select class="border rounded px-3 py-1 text-sm">
          <option>Showing {{ items.length }} content</option>
        </select>
        <select class="border rounded px-3 py-1 text-sm">
          <option>Newest</option>
        </select>
      </div>
    </div>

    <!-- Cards Grid -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
      <MeetingCard
        v-for="(item, i) in paginatedData"
        :key="i"
        :title="item.title"
        :description="item.description"
        :status="item.status"
        :date="item.formattedDate"
        :image="item.image || fallbackImage"
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
            <path fill-rule="evenodd" d="M11.354 1.646a.5.5 0 0 1 0 .708L5.707 8l5.647 5.646a.5.5 0 0 1-.708.708l-6-6a.5.5 0 0 1 0-.708l6-6a.5.5 0 0 1 .708 0"/>
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
          <span>{{ page }}</span>
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
            <path fill-rule="evenodd" d="M4.646 1.646a.5.5 0 0 1 .708 0l6 6a.5.5 0 0 1 0 .708l-6 6a.5.5 0 0 1-.708-.708L10.293 8 4.646 2.354a.5.5 0 0 1 0-.708"/>
          </svg>
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import MeetingCard from '@/components/Client/MeetingCard.vue'
import { serviceApi } from '@/api/service-api'
import fallbackImage from '@/assets/images/booking.jpg'

const items = ref([])
const currentPage = ref(1)
const perPage = 9

const fetchData = async () => {
  try {
    const services = await serviceApi.fetchServices()
    items.value = services.map(service => ({
      title: service.title,
      description: service.description,
      status: 'Available Now',
      date: service.date?.[0]?.date || '-',
      formattedDate: formatDate(service.date?.[0]?.date),
      image: service.image
    }))
  } catch (error) {
    console.error('Error fetching services:', error)
  }
}

const formatDate = (dateStr) => {
  if (!dateStr) return '-'
  const date = new Date(dateStr)
  return date.toLocaleDateString('en-US', {
    weekday: 'short',
    day: '2-digit',
    month: 'short',
    year: 'numeric'
  })
}

const paginatedData = computed(() => {
  const start = (currentPage.value - 1) * perPage
  return items.value.slice(start, start + perPage)
})

const totalPages = computed(() => Math.ceil(items.value.length / perPage))

const changePage = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
  }
}

onMounted(fetchData)
</script>
