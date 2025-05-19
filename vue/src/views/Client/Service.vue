<template>
  <div class="p-8 bg-gray-100 min-h-screen">
    <!-- Breadcrumb -->
    <div class="mb-6">
      <h1 class="text-2xl font-semibold">Services</h1>
      <nav class="text-sm text-gray-500">
        <router-link to="/client/dashboard" class="hover:underline">Dashboard</router-link> /
        <span class="text-indigo-600 capitalize">Services</span>
      </nav>
    </div>

    <!-- Meeting Cards -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
      <MeetingCard
        v-for="(item, i) in paginatedData"
        :key="i"
        :id="item.id"
        :title="item.title"
        :description="item.description"
        :status="'Available Now'"
        :image="item.image || fallbackImage"
        :option="item.option"
        :days="item.days"
        :time="item.time"
        :date="item.date"
        :endDate="item.endDate"
      />
    </div>

    <!-- Pagination -->
        <PaginationPage
      :currentPage="currentPage"
      :totalPages="totalPages"
      @page-change="changePage"
    />

  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { serviceApi } from '@/api/service-api'
import MeetingCard from '@/components/Client/card/ServiceCard.vue'
import fallbackImage from '@/assets/images/booking.jpg'
import PaginationPage from '@/components/Client/Pagination/PaginationPage.vue'

const items = ref([])
const currentPage = ref(1)
const perPage = 6

const fetchData = async () => {
  const data = await serviceApi.fetchServices()
  items.value = data.map(item => {
    const firstDate = item.date?.[0]?.date || null
    return {
      id: item.id,
      title: item.title,
      description: item.description,
      image: item.image,
      option: item.option?.join(', ') || '-',
      days: item.days?.join(', ') || '-',
      time: item.time?.join(', ') || '-',
      date: formatDate(firstDate),
      endDate: formatDate(item.end_date)
    }
  })
}

const formatDate = (dateStr) => {
  if (!dateStr) return '-'
  return new Date(dateStr).toLocaleDateString('en-US', {
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
  if (page >= 1 && page <= totalPages.value) currentPage.value = page
}

onMounted(fetchData)
</script>
