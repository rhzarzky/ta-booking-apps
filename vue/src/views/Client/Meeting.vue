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
          <option>Showing 9 content</option>
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
        :date="item.date"
        :image="item.image"
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
          <span>
            <svg
              xmlns="http://www.w3.org/2000/svg"
              width="16"
              height="16"
              fill="currentColor"
              class="bi bi-chevron-left"
              viewBox="0 0 16 16"
            >
              <path
                fill-rule="evenodd"
                d="M11.354 1.646a.5.5 0 0 1 0 .708L5.707 8l5.647 5.646a.5.5 0 0 1-.708.708l-6-6a.5.5 0 0 1 0-.708l6-6a.5.5 0 0 1 .708 0"
              />
            </svg>
          </span>
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
          <svg
            xmlns="http://www.w3.org/2000/svg"
            width="16"
            height="16"
            fill="currentColor"
            class="bi bi-chevron-right"
            viewBox="0 0 16 16"
          >
            <path
              fill-rule="evenodd"
              d="M4.646 1.646a.5.5 0 0 1 .708 0l6 6a.5.5 0 0 1 0 .708l-6 6a.5.5 0 0 1-.708-.708L10.293 8 4.646 2.354a.5.5 0 0 1 0-.708"
            />
          </svg>
        </button>
      </div>
    </div>
  </div>
</template>
<script setup>
import { ref, computed } from 'vue'
import MeetingCard from '@/components/Client/MeetingCard.vue'
import technicianImage from '@/assets/images/booking.jpg'

// Data dummy
const items = ref([
  {
    title: 'Service Electric 1',
    description:
      'Offering electrical services for your home, large city, and everything in between 1.',
    status: 'Available Now',
    date: 'Fri 07 Feb, 2025',
    image: technicianImage,
  },
  {
    title: 'Service Electric 2',
    description:
      'Offering electrical services for your home, large city, and everything in between 2.',
    status: 'Scheduled',
    date: 'Mon 10 Feb, 2025',
    image: technicianImage,
  },
  {
    title: 'Service Electric 3',
    description:
      'Offering electrical services for your home, large city, and everything in between 3.',
    status: 'Available Now',
    date: 'Wed 12 Feb, 2025',
    image: technicianImage,
  },
  {
    title: 'Service Electric 4',
    description:
      'Offering electrical services for your home, large city, and everything in between 4.',
    status: 'Scheduled',
    date: 'Fri 14 Feb, 2025',
    image: technicianImage,
  },
  {
    title: 'Service Electric 5',
    description:
      'Offering electrical services for your home, large city, and everything in between 5.',
    status: 'Available Now',
    date: 'Mon 17 Feb, 2025',
    image: technicianImage,
  },
  {
    title: 'Service Electric 6',
    description:
      'Offering electrical services for your home, large city, and everything in between 6.',
    status: 'Scheduled',
    date: 'Wed 19 Feb, 2025',
    image: technicianImage,
  },
  {
    title: 'Service Electric 7',
    description:
      'Offering electrical services for your home, large city, and everything in between 7.',
    status: 'Available Now',
    date: 'Fri 21 Feb, 2025',
    image: technicianImage,
  },
  {
    title: 'Service Electric 8',
    description:
      'Offering electrical services for your home, large city, and everything in between 8.',
    status: 'Scheduled',
    date: 'Mon 24 Feb, 2025',
    image: technicianImage,
  },
  {
    title: 'Service Electric 9',
    description:
      'Offering electrical services for your home, large city, and everything in between 9.',
    status: 'Available Now',
    date: 'Wed 26 Feb, 2025',
    image: technicianImage,
  },
  {
    title: 'Service Electric 10',
    description:
      'Offering electrical services for your home, large city, and everything in between 10.',
    status: 'Scheduled',
    date: 'Fri 28 Feb, 2025',
    image: technicianImage,
  },
  {
    title: 'Service Electric 11',
    description:
      'Offering electrical services for your home, large city, and everything in between 11.',
    status: 'Available Now',
    date: 'Mon 03 Mar, 2025',
    image: technicianImage,
  },
  {
    title: 'Service Electric 12',
    description:
      'Offering electrical services for your home, large city, and everything in between 12.',
    status: 'Scheduled',
    date: 'Wed 05 Mar, 2025',
    image: technicianImage,
  },
  {
    title: 'Service Electric 13',
    description:
      'Offering electrical services for your home, large city, and everything in between 13.',
    status: 'Available Now',
    date: 'Fri 07 Mar, 2025',
    image: technicianImage,
  },
  {
    title: 'Service Electric 14',
    description:
      'Offering electrical services for your home, large city, and everything in between 14.',
    status: 'Scheduled',
    date: 'Mon 10 Mar, 2025',
    image: technicianImage,
  },
  {
    title: 'Service Electric 15',
    description:
      'Offering electrical services for your home, large city, and everything in between 15.',
    status: 'Available Now',
    date: 'Wed 12 Mar, 2025',
    image: technicianImage,
  },
  {
    title: 'Service Electric 16',
    description:
      'Offering electrical services for your home, large city, and everything in between 16.',
    status: 'Scheduled',
    date: 'Fri 14 Mar, 2025',
    image: technicianImage,
  },
  {
    title: 'Service Electric 17',
    description:
      'Offering electrical services for your home, large city, and everything in between 17.',
    status: 'Available Now',
    date: 'Mon 17 Mar, 2025',
    image: technicianImage,
  },
  {
    title: 'Service Electric 18',
    description:
      'Offering electrical services for your home, large city, and everything in between 18.',
    status: 'Scheduled',
    date: 'Wed 19 Mar, 2025',
    image: technicianImage,
  },
  {
    title: 'Service Electric 19',
    description:
      'Offering electrical services for your home, large city, and everything in between 19.',
    status: 'Available Now',
    date: 'Fri 21 Mar, 2025',
    image: technicianImage,
  },
  {
    title: 'Service Electric 20',
    description:
      'Offering electrical services for your home, large city, and everything in between 20.',
    status: 'Scheduled',
    date: 'Mon 24 Mar, 2025',
    image: technicianImage,
  },
  {
    title: 'Service Electric 21',
    description:
      'Offering electrical services for your home, large city, and everything in between 21.',
    status: 'Available Now',
    date: 'Wed 26 Mar, 2025',
    image: technicianImage,
  },
  {
    title: 'Service Electric 22',
    description:
      'Offering electrical services for your home, large city, and everything in between 22.',
    status: 'Scheduled',
    date: 'Fri 28 Mar, 2025',
    image: technicianImage,
  },
  {
    title: 'Service Electric 23',
    description:
      'Offering electrical services for your home, large city, and everything in between 23.',
    status: 'Available Now',
    date: 'Mon 31 Mar, 2025',
    image: technicianImage,
  },
  {
    title: 'Service Electric 24',
    description:
      'Offering electrical services for your home, large city, and everything in between 24.',
    status: 'Scheduled',
    date: 'Wed 02 Apr, 2025',
    image: technicianImage,
  },
  {
    title: 'Service Electric 25',
    description:
      'Offering electrical services for your home, large city, and everything in between 25.',
    status: 'Available Now',
    date: 'Fri 04 Apr, 2025',
    image: technicianImage,
  },
  {
    title: 'Service Electric 26',
    description:
      'Offering electrical services for your home, large city, and everything in between 26.',
    status: 'Scheduled',
    date: 'Mon 07 Apr, 2025',
    image: technicianImage,
  },
  {
    title: 'Service Electric 27',
    description:
      'Offering electrical services for your home, large city, and everything in between 27.',
    status: 'Available Now',
    date: 'Wed 09 Apr, 2025',
    image: technicianImage,
  },
  {
    title: 'Service Electric 28',
    description:
      'Offering electrical services for your home, large city, and everything in between 28.',
    status: 'Scheduled',
    date: 'Fri 11 Apr, 2025',
    image: technicianImage,
  },
  {
    title: 'Service Electric 29',
    description:
      'Offering electrical services for your home, large city, and everything in between 29.',
    status: 'Available Now',
    date: 'Mon 14 Apr, 2025',
    image: technicianImage,
  },
  {
    title: 'Service Electric 30',
    description:
      'Offering electrical services for your home, large city, and everything in between 30.',
    status: 'Scheduled',
    date: 'Wed 16 Apr, 2025',
    image: technicianImage,
  },
  {
    title: 'Service Electric 31',
    description:
      'Offering electrical services for your home, large city, and everything in between 31.',
    status: 'Available Now',
    date: 'Fri 18 Apr, 2025',
    image: technicianImage,
  },
  {
    title: 'Service Electric 32',
    description:
      'Offering electrical services for your home, large city, and everything in between 32.',
    status: 'Scheduled',
    date: 'Mon 21 Apr, 2025',
    image: technicianImage,
  },
  {
    title: 'Service Electric 33',
    description:
      'Offering electrical services for your home, large city, and everything in between 33.',
    status: 'Available Now',
    date: 'Wed 23 Apr, 2025',
    image: technicianImage,
  },
  {
    title: 'Service Electric 34',
    description:
      'Offering electrical services for your home, large city, and everything in between 34.',
    status: 'Scheduled',
    date: 'Fri 25 Apr, 2025',
    image: technicianImage,
  },
  {
    title: 'Service Electric 35',
    description:
      'Offering electrical services for your home, large city, and everything in between 35.',
    status: 'Available Now',
    date: 'Mon 28 Apr, 2025',
    image: technicianImage,
  },
  {
    title: 'Service Electric 36',
    description:
      'Offering electrical services for your home, large city, and everything in between 36.',
    status: 'Scheduled',
    date: 'Wed 30 Apr, 2025',
    image: technicianImage,
  },
  {
    title: 'Service Electric 37',
    description:
      'Offering electrical services for your home, large city, and everything in between 37.',
    status: 'Available Now',
    date: 'Fri 02 May, 2025',
    image: technicianImage,
  },
  {
    title: 'Service Electric 38',
    description:
      'Offering electrical services for your home, large city, and everything in between 38.',
    status: 'Scheduled',
    date: 'Mon 05 May, 2025',
    image: technicianImage,
  },
  {
    title: 'Service Electric 39',
    description:
      'Offering electrical services for your home, large city, and everything in between 39.',
    status: 'Available Now',
    date: 'Wed 07 May, 2025',
    image: technicianImage,
  },
  {
    title: 'Service Electric 40',
    description:
      'Offering electrical services for your home, large city, and everything in between 40.',
    status: 'Scheduled',
    date: 'Fri 09 May, 2025',
    image: technicianImage,
  },
  {
    title: 'Service Electric 41',
    description:
      'Offering electrical services for your home, large city, and everything in between 41.',
    status: 'Available Now',
    date: 'Mon 12 May, 2025',
    image: technicianImage,
  },
  {
    title: 'Service Electric 42',
    description:
      'Offering electrical services for your home, large city, and everything in between 42.',
    status: 'Scheduled',
    date: 'Wed 14 May, 2025',
    image: technicianImage,
  },
  {
    title: 'Service Electric 43',
    description:
      'Offering electrical services for your home, large city, and everything in between 43.',
    status: 'Available Now',
    date: 'Fri 16 May, 2025',
    image: technicianImage,
  },
  {
    title: 'Service Electric 44',
    description:
      'Offering electrical services for your home, large city, and everything in between 44.',
    status: 'Scheduled',
    date: 'Mon 19 May, 2025',
    image: technicianImage,
  },
  {
    title: 'Service Electric 45',
    description:
      'Offering electrical services for your home, large city, and everything in between 45.',
    status: 'Available Now',
    date: 'Wed 21 May, 2025',
    image: technicianImage,
  },
  {
    title: 'Service Electric 46',
    description:
      'Offering electrical services for your home, large city, and everything in between 46.',
    status: 'Scheduled',
    date: 'Fri 23 May, 2025',
    image: technicianImage,
  },
  {
    title: 'Service Electric 47',
    description:
      'Offering electrical services for your home, large city, and everything in between 47.',
    status: 'Available Now',
    date: 'Mon 26 May, 2025',
    image: technicianImage,
  },
  {
    title: 'Service Electric 48',
    description:
      'Offering electrical services for your home, large city, and everything in between 48.',
    status: 'Scheduled',
    date: 'Wed 28 May, 2025',
    image: technicianImage,
  },
  {
    title: 'Service Electric 49',
    description:
      'Offering electrical services for your home, large city, and everything in between 49.',
    status: 'Available Now',
    date: 'Fri 30 May, 2025',
    image: technicianImage,
  },
  {
    title: 'Service Electric 50',
    description:
      'Offering electrical services for your home, large city, and everything in between 50.',
    status: 'Scheduled',
    date: 'Mon 02 Jun, 2025',
    image: technicianImage,
  },
])

// State dan logic
const currentPage = ref(1)
const perPage = 9

const totalPages = computed(() => {
  return Math.ceil(items.value.length / perPage)
})

const paginatedData = computed(() => {
  const start = (currentPage.value - 1) * perPage
  const end = start + perPage
  return items.value.slice(start, end)
})

function changePage(page) {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
  }
}
</script>
