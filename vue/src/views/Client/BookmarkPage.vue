<template>
  <div class="p-4 bg-gray-50 min-h-screen font-sans">
    <div class="bg-white p-6 shadow-lg rounded-xl mb-6">
      <h1 class="text-3xl font-extrabold text-gray-900 mb-2">My Bookmarked Services</h1>
      <p class="text-gray-600">All the services you've saved.</p>
    </div>

    <div v-if="loadingServices" class="text-center py-10 text-gray-600 text-lg">
      Loading your bookmarked services...
    </div>
    <div v-else-if="bookmarkedServices.length > 0" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-8">
      <ServiceCard
        v-for="item in bookmarkedServices"
        :key="item.id"
        :id="item.id"
        :title="item.title"
        :description="item.description"
        :status="item.status"
        :image="item.image || fallbackImage"
        :option="item.option"
        :days="item.days"
        :time="item.time"
        :date="item.date"
        :endDate="item.endDate"
      />
    </div>
    <div v-else class="text-center py-10 text-gray-600 text-lg">
      You haven't bookmarked any services yet.
      <router-link to="/client/service" class="text-indigo-600 hover:underline ml-2">
        Browse services
      </router-link>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue';
import { useBookmarkStore } from '@/stores/bookmark';
import { useServiceStore } from '@/stores/service';
import fallbackImage from '@/assets/images/booking.jpg'; // Sesuaikan path ini jika perlu
import ServiceCard from '@/components/Client/card/ServiceCard.vue';

const bookmarkStore = useBookmarkStore();
const serviceStore = useServiceStore();

const loadingServices = ref(true);

// Computed property untuk mendapatkan detail layanan yang dibookmark
const bookmarkedServices = computed(() => {
  const filtered = [];
  const bookmarkedIds = bookmarkStore.bookmarkedServiceIds;

  // Pastikan data layanan sudah terload sebelum memfilter
  if (serviceStore.services.length === 0) {
    return [];
  }

  for (const id of bookmarkedIds) {
    const service = serviceStore.services.find(s => s.id === id);
    if (service) {
      // Format data sesuai dengan yang diterima oleh BookmarkItem
      const firstDate = service.date?.[0]?.date || null;
      filtered.push({
        id: service.id,
        title: service.title,
        description: service.description,
        image: service.image,
        option: service.option?.join(', ') || '-',
        days: service.days?.join(', ') || '-',
        time: service.time?.join(', ') || '-',
        date: formatDisplayDate(firstDate),
        endDate: formatDisplayDate(service.end_date),
        status: 'Available Now' // Anda mungkin perlu logika status yang lebih kompleks di sini
      });
    }
  }
  return filtered;
});

// Helper function untuk format tanggal (sama seperti di component Service.vue)
const formatDisplayDate = (dateStr) => {
  if (!dateStr) return '-';
  return new Date(dateStr).toLocaleDateString('en-US', {
    weekday: 'short',
    day: '2-digit',
    month: 'short',
    year: 'numeric'
  });
};

// Lifecycle hook untuk mengambil data layanan jika belum ada
onMounted(async () => {
  if (serviceStore.services.length === 0) {
    loadingServices.value = true;
    await serviceStore.fetchServices();
    loadingServices.value = false;
  } else {
    loadingServices.value = false;
  }
});

// Watch bookmarkStore.bookmarkedServiceIds untuk re-render jika ada perubahan bookmark
// computed property bookmarkedServices akan secara otomatis re-evaluate ketika bookmarkedServiceIds berubah
watch(bookmarkStore.bookmarkedServiceIds, () => {
  // Hanya log untuk debugging, computed property sudah reaktif
  console.log("Bookmarked IDs changed, refreshing services.");
});
</script>