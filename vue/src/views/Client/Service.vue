<template>
  <div class="p-4 bg-gray-50 min-h-screen font-sans">

    <div class="flex flex-col md:flex-row gap-4 mb-8 p-6 bg-white rounded-xl shadow-lg border border-gray-200">
      <div class="relative flex-grow">
        <input
          type="text"
          v-model="searchQuery"
          placeholder="Search by title or description..."
          class="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 transition duration-200"
        />
        <svg class="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24" width="20" height="20" xmlns="http://www.w3.org/2000/svg">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
        </svg>
      </div>

      <div class="relative md:w-1/4">
        <select
          v-model="selectedOption"
          class="block appearance-none w-full bg-white border border-gray-300 text-gray-700 py-2 px-4 pr-8 rounded-lg leading-tight focus:outline-none focus:bg-white focus:border-indigo-500 transition duration-200"
        >
          <option value="">All Options</option>
          <option v-for="opt in uniqueOptions" :key="opt" :value="opt">{{ opt }}</option>
        </select>
        <div class="pointer-events-none absolute inset-y-0 right-0 flex items-center px-2 text-gray-700">
          <svg class="fill-current h-4 w-4" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"><path d="M9.293 12.95l.707.707L15.657 8l-1.414-1.414L10 10.828 5.757 6.586 4.343 8z"/></svg>
        </div>
      </div>

      <div class="relative md:w-1/4">
        <select
          v-model="selectedDay"
          class="block appearance-none w-full bg-white border border-gray-300 text-gray-700 py-2 px-4 pr-8 rounded-lg leading-tight focus:outline-none focus:bg-white focus:border-indigo-500 transition duration-200"
        >
          <option value="">All Days</option>
          <option v-for="day in uniqueDays" :key="day" :value="day">{{ day }}</option>
        </select>
        <div class="pointer-events-none absolute inset-y-0 right-0 flex items-center px-2 text-gray-700">
          <svg class="fill-current h-4 w-4" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"><path d="M9.293 12.95l.707.707L15.657 8l-1.414-1.414L10 10.828 5.757 6.586 4.343 8z"/></svg>
        </div>
      </div>
    </div>

    <div v-if="paginatedData.length > 0" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-8">
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
    <div v-else class="text-center py-10 text-gray-600 text-lg">
      No services found matching your criteria.
    </div>

    <PaginationPage
      :currentPage="currentPage"
      :totalPages="totalPages"
      @page-change="changePage"
      class="mt-10 flex justify-center"
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { serviceApi } from '@/api/service-api';
import MeetingCard from '@/components/Client/card/ServiceCard.vue';
import PaginationPage from '@/components/Client/Pagination/PaginationPage.vue';
import fallbackImage from '@/assets/images/booking.jpg'; // Pastikan path ini benar

// --- State Management ---
const services = ref([]); 
const currentPage = ref(1);
const servicesPerPage = 6;

// --- Filter & Search States ---
const searchQuery = ref('');
const selectedOption = ref('');
const selectedDay = ref('');

// --- Data Fetching ---
const fetchServicesData = async () => {
  const data = await serviceApi.fetchServices();
  services.value = data.map(item => {
    const firstDate = item.date?.[0]?.date || null;
    return {
      id: item.id,
      title: item.title,
      description: item.description,
      image: item.image,
      option: item.option?.join(', ') || '-',
      days: item.days?.join(', ') || '-',
      time: item.time?.join(', ') || '-',
      date: formatDisplayDate(firstDate),
      endDate: formatDisplayDate(item.end_date)
    };
  });
};

// --- Helper Functions ---
const formatDisplayDate = (dateStr) => {
  if (!dateStr) return '-';
  return new Date(dateStr).toLocaleDateString('en-US', {
    weekday: 'short',
    day: '2-digit',
    month: 'short',
    year: 'numeric'
  });
};

// --- Computed Properties for Filters ---
const uniqueOptions = computed(() => {
  const options = new Set();
  services.value.forEach(service => {
    if (service.option && service.option !== '-') {
      service.option.split(', ').forEach(opt => options.add(opt.trim()));
    }
  });
  return Array.from(options).sort();
});

const uniqueDays = computed(() => {
  const days = new Set();
  services.value.forEach(service => {
    if (service.days && service.days !== '-') {
      service.days.split(', ').forEach(day => days.add(day.trim()));
    }
  });
  // Sort days in a specific order (Mon, Tue, Wed...)
  const order = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return Array.from(days).sort((a, b) => {
    const dayA = a.substring(0, 3); // Get first 3 letters for comparison
    const dayB = b.substring(0, 3);
    return order.indexOf(dayA) - order.indexOf(dayB);
  });
});

// --- Computed Properties for Filtered, Searched, and Paginated Data ---
const filteredAndSearchedServices = computed(() => {
  let filteredServices = services.value;

  // Apply Search
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase();
    filteredServices = filteredServices.filter(service =>
      service.title.toLowerCase().includes(query) ||
      service.description.toLowerCase().includes(query)
    );
  }

  // Apply Option Filter
  if (selectedOption.value) {
    filteredServices = filteredServices.filter(service =>
      service.option.includes(selectedOption.value)
    );
  }

  // Apply Day Filter
  if (selectedDay.value) {
    filteredServices = filteredServices.filter(service =>
      service.days.includes(selectedDay.value)
    );
  }

  // Reset currentPage to 1 when filters or search criteria change
  currentPage.value = 1;
  return filteredServices;
});

const paginatedData = computed(() => {
  const start = (currentPage.value - 1) * servicesPerPage;
  const end = start + servicesPerPage;
  return filteredAndSearchedServices.value.slice(start, end);
});

const totalPages = computed(() =>
  Math.ceil(filteredAndSearchedServices.value.length / servicesPerPage)
);

// --- Pagination Actions ---
const changePage = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page;
  }
};

// --- Lifecycle Hook ---
onMounted(fetchServicesData);
</script>