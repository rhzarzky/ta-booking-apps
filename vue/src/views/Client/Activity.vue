<script setup>
import { ref, computed, onMounted, watch } from 'vue';
import { useBookingStore } from '@/stores/booking';
import ActivityCard from '@/components/Client/card/ActivityCard.vue';
import ReviewModal from '@/components/Client/modals/ReviewModal.vue';
import PaginationPage from '@/components/Client/Pagination/PaginationPage.vue';
import { bookingApi } from '@/api/booking-api';

// Store dan pagination
const bookingStore = useBookingStore();
const currentPage = ref(1);
const perPage = 5;

// Filter states
const selectedStatus = ref('All');
const selectedDate = ref('');
const searchQuery = ref('');

// State untuk modal review
const showReviewModal = ref(false);
const currentBookingIdForReview = ref(0);

// Map untuk menyimpan data status tambahan (completion, canReview, review) untuk setiap booking
// Key: id_booking, Value: { completionStatus, canReview, localReview }
const bookingExtraStatusData = ref(new Map());

// Loading state khusus untuk data tambahan
const loadingExtraData = ref(false);

/**
 * Mengambil semua data status tambahan (completion, canReview, review)
 * untuk semua booking secara paralel (batch loading).
 */
const fetchAndProcessAllBookingExtraData = async () => {
  loadingExtraData.value = true;
  const newBookingExtraStatusData = new Map();
  const promises = bookings.value.map(async (booking) => {
    const id = booking.id_booking;
    let completionStatus = null;
    let canReview = false;
    let localReview = null;

    try {
      // Melakukan semua panggilan API secara paralel untuk setiap booking
      const [completionRes, canReviewRes, reviewRes] = await Promise.all([
        bookingApi.getCompletionStatus(id),
        bookingApi.canReview(id),
        bookingApi.getReview(id)
      ]);

      completionStatus = completionRes.data?.completion_status || completionRes.completion_status || null;
      canReview = canReviewRes?.can_review || false;
      
      const fetchedReview = reviewRes?.review || reviewRes?.data?.review || null;
      // Hanya set localReview jika review benar-benar sudah disubmit (memiliki rating dan reviewed_at)
      if (fetchedReview && fetchedReview.rating !== null && fetchedReview.reviewed_at !== null) {
        localReview = fetchedReview;
      }

    } catch (error) {
      console.error(`[Activity.vue] Failed to fetch extra data for booking ${id}:`, error);
      // Biarkan null atau default jika ada error pada salah satu fetch
    }

    newBookingExtraStatusData.set(id, {
      completionStatus,
      canReview,
      localReview,
    });
  });

  await Promise.all(promises); // Tunggu sampai semua promise selesai
  bookingExtraStatusData.value = newBookingExtraStatusData; // Update map setelah semua selesai
  loadingExtraData.value = false;
  console.log(`[Activity.vue] Semua data status tambahan berhasil dimuat untuk ${bookings.value.length} booking.`);
};


// Ambil data booking utama saat komponen dimuat, lalu ambil data tambahan
onMounted(() => {
  bookingStore.fetchUserBookings().then(async () => {
    await fetchAndProcessAllBookingExtraData();
  });
});

// Reset currentPage ke 1 saat filter tanggal atau status berubah
watch([selectedStatus, selectedDate], () => {
  currentPage.value = 1;
});

// Reset currentPage ke 1 saat search query berubah
watch(searchQuery, () => {
  currentPage.value = 1;
});

// Semua data booking dari store, diurutkan dari ID terbesar ke terkecil
const bookings = computed(() => {
  return Object.values(bookingStore.bookingsByStatus)
    .flat()
    .sort((a, b) => b.id_booking - a.id_booking);
});

// Watch bookings data changes to re-fetch extra statuses
// Menggunakan deep: false untuk performa karena hanya perlu memantau perubahan ID/jumlah, bukan detail objek.
watch(bookings, async (newBookings, oldBookings) => {
    if (newBookings.length !== oldBookings.length || newBookings.some((b, i) => b.id_booking !== oldBookings[i]?.id_booking)) {
        await fetchAndProcessAllBookingExtraData();
    }
}, { deep: false });


/**
 * Helper untuk menghitung 'displayStatus' sebuah booking berdasarkan data yang sudah di-fetch.
 * Logika ini harus konsisten dengan yang ada di ActivityCard.vue.
 */
const getDisplayStatusForBooking = (booking) => {
    const extraData = bookingExtraStatusData.value.get(booking.id_booking) || {};
    const { completionStatus, canReview, localReview } = extraData;

    const currentMainStatus = (booking?.status || '').toLowerCase();
    const currentCompletionStatus = (completionStatus || '').toLowerCase();

    if (localReview) {
        return 'Completed'; // Sudah direview
    } else if (currentCompletionStatus === 'completed - awaiting review' && canReview) {
        return 'Menunggu Review'; // Menunggu review dan bisa direview
    } else if (currentCompletionStatus === 'declined review' || currentMainStatus === 'declined') {
        return 'Declined'; // Review ditolak atau booking ditolak
    } else if (currentMainStatus === 'approved') {
        return 'Approved';
    } else if (currentMainStatus === 'pending') {
        return 'Pending';
    }
    return currentMainStatus || '-'; // Fallback
};

// Filter data berdasarkan status, tanggal, dan search query
const filteredBookings = computed(() => {
  return bookings.value.filter((booking) => {
    const finalDisplayStatus = getDisplayStatusForBooking(booking);

    // Filter berdasarkan status kustom yang dihitung
    const matchStatus = selectedStatus.value === 'All' || finalDisplayStatus === selectedStatus.value;
    
    // Filter berdasarkan tanggal
    const matchDate = !selectedDate.value || booking.date === selectedDate.value;
    
    // Filter berdasarkan search query di berbagai kolom
    const matchSearch =
      !searchQuery.value ||
      booking.service?.title?.toLowerCase().includes(searchQuery.value.toLowerCase()) ||
      booking.service?.description?.toLowerCase().includes(searchQuery.value.toLowerCase()) || 
      booking.option?.toLowerCase().includes(searchQuery.value.toLowerCase()) || 
      booking.note?.toLowerCase().includes(searchQuery.value.toLowerCase());

    return matchStatus && matchDate && matchSearch;
  });
});

// Hitung total booking per status berdasarkan status yang dihitung (displayStatus)
const bookingCounts = computed(() => {
  const counts = {
    All: 0,
    Pending: 0,
    Approved: 0,
    'Menunggu Review': 0, // Status kustom
    Completed: 0,        // Status kustom
    Declined: 0,
  };

  bookings.value.forEach((booking) => { // Hitung dari semua booking, bukan hanya yang difilter
    const finalDisplayStatus = getDisplayStatusForBooking(booking);
    if (finalDisplayStatus && counts.hasOwnProperty(finalDisplayStatus)) {
      counts[finalDisplayStatus]++;
    }
    counts.All++;
  });

  return counts;
});

// Pagination
const paginatedBookings = computed(() => {
  const start = (currentPage.value - 1) * perPage;
  const end = start + perPage;
  return filteredBookings.value.slice(start, end);
});

const totalPages = computed(() => {
  return Math.max(1, Math.ceil(filteredBookings.value.length / perPage));
});

function changePage(page) {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page;
  }
}

// Global loading state: True jika data booking utama atau data tambahan sedang dimuat
const globalLoading = computed(() => bookingStore.loading || loadingExtraData.value);

// Fungsi untuk menangani event "Tulis Review" dari ActivityCard
const handleGoToReviewForm = (bookingId) => {
  console.log(`[Activity.vue] Menerima event go-to-review-form untuk Booking ID: ${bookingId}`);
  currentBookingIdForReview.value = bookingId;
  showReviewModal.value = true;
};

// Fungsi untuk menangani penutupan modal review
const handleCloseReviewModal = () => {
  console.log('[Activity.vue] Menutup modal review. Resetting bookingId.');
  showReviewModal.value = false;
  currentBookingIdForReview.value = 0;
};

// Fungsi untuk menangani setelah review berhasil di-submit
const handleReviewSubmitted = () => {
  console.log('[Activity.vue] Review berhasil di-submit! Memuat ulang data booking dan status tambahan.');
  handleCloseReviewModal();
  // Refresh data booking utama dan kemudian refresh data status tambahan
  bookingStore.fetchUserBookings().then(async () => {
    await fetchAndProcessAllBookingExtraData();
  });
};

// Fungsi untuk menangani saat status booking diperbarui (misalnya, Selesaikan Booking)
const handleBookingStatusUpdated = () => {
  console.log('[Activity.vue] Booking status diperbarui! Memuat ulang data booking dan status tambahan.');
  // Refresh data booking utama dan kemudian refresh data status tambahan
  bookingStore.fetchUserBookings().then(async () => {
    await fetchAndProcessAllBookingExtraData();
  });
};
</script>

<template>
  <div class="bg-gray-100 min-h-screen p-4">
    <div class="max-w-4xl mx-auto">
      <div class="mb-6 bg-white rounded-lg shadow p-6">
        <h1 class="text-3xl font-bold text-gray-800 mb-6">Your Booking Activity</h1>
        <div class="flex flex-wrap gap-4 text-sm">
          <div class="flex-grow">
            <label for="date-filter" class="sr-only">Filter by Date</label>
            <input
              id="date-filter"
              type="date"
              v-model="selectedDate"
              class="border px-3 py-2 rounded-lg w-full focus:ring-blue-500 focus:border-blue-500"
            />
          </div>

          <div class="flex-grow sm:flex-grow-0 sm:w-64">
            <label for="search-input" class="sr-only">Search Bookings</label>
            <input
              id="search-input"
              type="text"
              v-model="searchQuery"
              placeholder="Search by title, description, or notes..."
              class="border px-3 py-2 rounded-lg w-full focus:ring-blue-500 focus:border-blue-500"
            />
          </div>

          <div class="flex flex-wrap gap-3 mt-4 sm:mt-0">
            <button
              v-for="status in ['All', 'Pending', 'Approved', 'Completed', 'Declined']"
              :key="status"
              :class="[
                'border px-4 py-2 rounded-lg font-medium transition-colors duration-200 ease-in-out',
                selectedStatus === status
                  ? 'bg-blue-600 text-white shadow'
                  : 'bg-white text-gray-700 hover:bg-gray-50'
              ]"
              @click="selectedStatus = status"
            >
              {{ status }} ({{ bookingCounts[status] || 0 }})
            </button>
          </div>
        </div>
      </div>

      <div>
        <div v-if="globalLoading" class="text-center py-10 text-gray-500 text-lg">
          <svg class="animate-spin h-8 w-8 text-blue-500 mx-auto mb-3" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
          </svg>
          Loading booking activity...
        </div>
        <div v-else-if="filteredBookings.length === 0" class="bg-white rounded-lg shadow p-6 text-center text-gray-600">
          <p class="text-lg">No booking activities available.</p>
          <p class="text-sm mt-2">Try customizing your filters or create a new booking!</p>
        </div>
        <ActivityCard
          v-else
          v-for="item in paginatedBookings"
          :key="item.id_booking"
          :booking="item"
          :extraStatusData="bookingExtraStatusData.get(item.id_booking)"
          class="mb-4 transition-all duration-300 ease-in-out transform hover:scale-[1.01] hover:shadow-lg"
          @go-to-review-form="handleGoToReviewForm"
          @booking-status-updated="handleBookingStatusUpdated"
        />
      </div>

      <div v-if="totalPages > 1" class="mt-8">
        <PaginationPage
          :currentPage="currentPage"
          :totalPages="totalPages"
          @page-change="changePage"
        />
      </div>
    </div>

  <ReviewModal
    :show="showReviewModal"
    :bookingId="currentBookingIdForReview" 
    @close="handleCloseReviewModal"
    @review-submitted="handleReviewSubmitted"
  />
  </div>
</template>