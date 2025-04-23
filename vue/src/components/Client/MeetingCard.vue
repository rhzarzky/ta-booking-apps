<template>
  <div class="bg-white rounded-lg shadow p-4">
    <img :src="image" alt="Technician" class="h-40 w-full object-cover rounded-lg mb-4" />
    <h2 class="text-sm font-semibold mb-1">{{ title }}</h2>
    <p class="text-xs text-gray-600 mb-2">{{ description }}</p>
    <div class="text-xs flex justify-between mb-1">
      <span :class="statusClass">{{ status }}</span>
      <span class="bg-gray-100 text-gray-700 px-2 py-1 rounded">Schedule From</span>
    </div>
    <div class="text-xs text-gray-500 mb-4 flex justify-between">
      <span>3+ Ways to Meet</span> 
      <span class="ml-2">{{ date }}</span>
    </div>
    <button
      @click="goToDetail"
      class="w-full bg-indigo-600 text-white text-sm py-2 rounded hover:bg-indigo-700"
    >
      Book Appointment
    </button>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useRouter } from 'vue-router'

// Props
const props = defineProps({
  title: String,
  description: String,
  status: String,
  date: String,
  image: String,
})

// Routing
const router = useRouter()
function goToDetail() {
  router.push({
    name: 'client-detail-booking',
    query: {
      title: props.title,
      description: props.description,
      status: props.status,
      date: props.date,
      image: props.image,
    }
  })
}


// Computed class based on status
const statusClass = computed(() => {
  return props.status === 'Available Now'
    ? 'bg-green-100 text-green-700 px-2 py-1 rounded'
    : 'bg-gray-100 text-gray-700 px-2 py-1 rounded'
})
</script>
