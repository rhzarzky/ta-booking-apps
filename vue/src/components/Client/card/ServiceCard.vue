<template>
  <div class="bg-white rounded-lg shadow p-4">
    <img :src="image" alt="Service" class="h-40 w-full object-cover rounded mb-4" />
    
    <h2 class="text-sm font-semibold mb-1">{{ title }}</h2>
    <p class="text-xs text-gray-600 mb-2">{{ description }}</p>

    <div class="text-xs flex justify-between mb-1">
      <span :class="statusClass">{{ status }}</span>
      <span class="bg-gray-100 text-gray-700 px-2 py-1 rounded">Schedule</span>
    </div>

    <div class="text-xs text-gray-500 space-y-1 mb-4">
      <div><strong>Option:</strong> {{ option }}</div>
      <div><strong>Days:</strong> {{ days }}</div>
      <div><strong>Time:</strong> {{ time }}</div>
      <div><strong>Date:</strong> {{ date }} – {{ endDate }}</div>
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
import { useRouter } from 'vue-router'
import { computed } from 'vue'

const props = defineProps({
  id: Number,
  title: String,
  description: String,
  status: String,
  date: String,
  endDate: String,
  option: String,
  days: String,
  time: String,
  image: String
})

const router = useRouter()

const goToDetail = () => {
  router.push({ name: 'client-detail-service', params: { id: props.id } })
}

const statusClass = computed(() =>
  props.status === 'Available Now'
    ? 'bg-green-100 text-green-700 px-2 py-1 rounded'
    : 'bg-gray-100 text-gray-700 px-2 py-1 rounded'
)
</script>
