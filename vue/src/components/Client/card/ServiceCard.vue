<template>
  <div class="bg-white rounded-xl shadow-md overflow-hidden transform hover:scale-102 transition duration-300 ease-in-out">
    <img :src="image" alt="Service" class="h-48 w-full object-cover" />

    <div class="p-5">
      <h2 class="text-xl font-bold text-gray-900 mb-2 truncate">{{ title }}</h2>
      <p class="text-sm text-gray-600 mb-3 line-clamp-2">{{ description }}</p>

      <div class="flex justify-between items-center text-xs mb-3">
        <span :class="statusClass">{{ status }}</span>
        <span class="bg-indigo-50 text-indigo-700 px-3 py-1 rounded-full font-medium">Schedule</span>
      </div>

      <div class="text-sm text-gray-500 space-y-1 mb-5">
        <div><strong>Option:</strong> {{ option }}</div>
        <div><strong>Days:</strong> {{ days }}</div>
        <div><strong>Time:</strong> {{ time }}</div>
        <div><strong>Date:</strong> {{ date }} – {{ endDate }}</div>
      </div>

      <button
        @click="goToDetail"
        class="w-full bg-indigo-600 text-white font-semibold py-2.5 rounded-lg hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-opacity-50 transition duration-300"
      >
        Book Appointment
      </button>
    </div>
  </div>
</template>

<script setup>
import { useRouter } from 'vue-router';
import { computed } from 'vue';

// --- Props Definition ---
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
});

const router = useRouter();

// --- Computed Properties ---
const statusClass = computed(() =>
  props.status === 'Available Now'
    ? 'bg-green-100 text-green-700 px-3 py-1 rounded-full font-medium'
    : 'bg-gray-100 text-gray-700 px-3 py-1 rounded-full font-medium'
);

// --- Actions ---
const goToDetail = () => {
  router.push({ name: 'client-detail-service', params: { id: props.id } });
};
</script>