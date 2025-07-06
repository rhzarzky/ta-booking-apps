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

      <button
        @click="goToMyBookmarks"
        class="flex-shrink-0 bg-indigo-600 hover:bg-indigo-700 text-white font-semibold py-2 px-4 rounded-lg
               flex items-center justify-center transition duration-200 shadow-md focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-opacity-50"
        aria-label="Go to My Bookmarks"
      >
        <svg class="w-5 h-5 mr-2" fill="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path d="M17 3H7c-1.1 0-2 .9-2 2v16l7-3 7 3V5c0-1.1-.9-2-2-2z"/>
        </svg>
        My Bookmarks <span v-if="bookmarkCount > 0" class="ml-1">({{ bookmarkCount }})</span>
      </button>
    </div>

    <div v-if="isLoading" class="flex flex-col items-center justify-center h-64 text-gray-600">
      <div class="animate-spin rounded-full h-16 w-16 border-4 border-indigo-500 border-t-transparent mb-4"></div>
      <p class="text-lg">Loading services...</p>
    </div>

    <div v-else-if="paginatedData.length > 0" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-8">
      <ServiceCard v-for="(item, i) in paginatedData"
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
        :averageRating="item.averageRating"
        :reviewCount="item.reviewCount" />
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
import { ref, computed, onMounted, watch } from 'vue'; // Tambahkan 'watch' di sini
import { useRouter } from 'vue-router';
import { serviceApi } from '@/api/service-api';
import ServiceCard from '@/components/Client/card/ServiceCard.vue';
import PaginationPage from '@/components/Client/Pagination/PaginationPage.vue';
import fallbackImage from '@/assets/images/booking.jpg';
import { useBookmarkStore } from '@/stores/bookmark';

// --- Vue Router ---
const router = useRouter();

// --- Store Management ---
const bookmarkStore = useBookmarkStore();

// --- State Management ---
const services = ref([]);
const currentPage = ref(1);
const servicesPerPage = 6;
const isLoading = ref(true); // New loading state

// --- Filter & Search States ---
const searchQuery = ref('');
const selectedOption = ref('');
const selectedDay = ref('');

// --- Data Fetching ---
const fetchServicesData = async () => {
  isLoading.value = true; // Set loading to true at the start
  try {
    const data = await serviceApi.fetchServices();
    services.value = await Promise.all(
      data.map(async (item) => {
        const firstDate = item.date?.[0]?.date || null;

        let averageRating = 0;
        let reviewCount = 0;
        try {
          const reviews = await serviceApi.fetchServiceReviews(item.id);
          if (reviews.length > 0) {
            const total = reviews.reduce((sum, r) => sum + r.rating, 0);
            averageRating = (total / reviews.length).toFixed(1);
            reviewCount = reviews.length;
          }
        } catch (err) {
          console.warn(`Failed to fetch reviews for service ID ${item.id}`, err);
        }

        return {
          id: item.id,
          title: item.title,
          description: item.description,
          image: item.image,
          // Pastikan item.option dan item.days di-join hanya jika itu array
          option: Array.isArray(item.option) ? item.option.join(', ') : (item.option || '-'),
          days: Array.isArray(item.days) ? item.days.join(', ') : (item.days || '-'),
          time: Array.isArray(item.time) ? item.time.join(', ') : (item.time || '-'),
          date: formatDisplayDate(firstDate),
          endDate: formatDisplayDate(item.end_date),
          averageRating,
          reviewCount,
        };
      })
    );
  } catch (error) {
    console.error("Failed to fetch services:", error);
    // Optionally, you can add a user-facing error message here
  } finally {
    isLoading.value = false; // Set loading to false when done (success or error)
  }
};

// --- Helper Functions ---
const formatDisplayDate = (dateStr) => {
  if (!dateStr) return '-';
  // Menggunakan 'id-ID' sesuai permintaan awal Anda untuk format tanggal
  // Jika ingin English: 'en-US'
  return new Date(dateStr).toLocaleDateString('id-ID', {
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
    // Memastikan service.option adalah string sebelum split
    if (service.option && service.option !== '-') {
      service.option.split(', ').forEach(opt => options.add(opt.trim()));
    }
  });
  return Array.from(options).sort();
});

const uniqueDays = computed(() => {
  const days = new Set();
  services.value.forEach(service => {
    // Memastikan service.days adalah string sebelum split
    if (service.days && service.days !== '-') {
      service.days.split(', ').forEach(day => days.add(day.trim()));
    }
  });
  const order = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return Array.from(days).sort((a, b) => {
    const dayA = a.substring(0, 3);
    const dayB = b.substring(0, 3);
    return order.indexOf(dayA) - order.indexOf(dayB);
  });
});

const bookmarkCount = computed(() => bookmarkStore.totalBookmarks);


// --- Computed Properties for Filtered, Searched, and Paginated Data ---
const filteredAndSearchedServices = computed(() => {
  let filteredServices = services.value;

  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase();
    filteredServices = filteredServices.filter(service =>
      service.title.toLowerCase().includes(query) ||
      service.description.toLowerCase().includes(query)
    );
  }

  if (selectedOption.value) {
    filteredServices = filteredServices.filter(service =>
      service.option.includes(selectedOption.value)
    );
  }

  if (selectedDay.value) {
    filteredServices = filteredServices.filter(service =>
      service.days.includes(selectedDay.value)
    );
  }

  return filteredServices;
});

// Watch for changes in filteredAndSearchedServices to reset currentPage
watch(filteredAndSearchedServices, () => {
  currentPage.value = 1;
}); // Tidak perlu deep: true di sini karena filteredAndSearchedServices adalah array baru setiap kali berubah

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

// --- Bookmark Navigation Action ---
const goToMyBookmarks = () => {
  router.push({ name: 'client-bookmarks' });
};

// --- Lifecycle Hook ---
onMounted(fetchServicesData);
</script>