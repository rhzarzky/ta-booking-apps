<script setup>
import { ref, onMounted, computed, watch, nextTick } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useServiceStore } from '@/stores/service'
import fallbackImage from '@/assets/images/booking.jpg'
import ReviewSummary from '@/components/Client/Review/ReviewSummary.vue';
import AllReviewsModal from '@/components/Client/modals/AllReviewsModal.vue';

import DatePicker from 'vue-datepicker-next';
import 'vue-datepicker-next/index.css';
// --- PERBAIKAN UTAMA: Hapus baris ini jika ada dan ganti dengan yang di bawahnya ---
// import 'vue-datepicker-next/locale/id';
// --- Impor objek locale secara eksplisit ---
import idLocale from 'vue-datepicker-next/locale/id';


// Import icons from lucide-vue-next
import {
  MapPin,
  ListChecks,
  CalendarClock,
  ClipboardEdit,
  Clock,
  CalendarDays,
} from 'lucide-vue-next'


// --- Notification System Setup ---
const notifications = ref([]);
let notificationId = 0;

const showNotification = (type, message) => {
  const id = notificationId++;
  notifications.value.push({ id, type, message });
  setTimeout(() => {
    removeNotification(id);
  }, 5000); // Notifications disappear after 5 seconds
};

const removeNotification = (id) => {
  notifications.value = notifications.value.filter(n => n.id !== id);
};
// --- End Notification System Setup ---

const route = useRoute()
const router = useRouter()
const store = useServiceStore()
const service = ref(null)
const isSubmitting = ref(false)
const isLoadingService = ref(true)

const form = ref({
  date: null, // Will store Date object from calendar
  time: '',
  option: '',
  note: '',
})

// === Bagian untuk Review ===
const serviceReviews = ref([]); // Menyimpan semua review
const showAllReviewsModal = ref(false); // State untuk menampilkan/menyembunyikan modal

// Fungsi untuk membuka modal semua review
const openAllReviewsModal = () => {
  showAllReviewsModal.value = true;
};

// Fungsi untuk menutup modal semua review
const closeAllReviewsModal = () => {
  showAllReviewsModal.value = false;
};
// === Akhir Bagian untuk Review ===


// Computed property for available dates formatted for DatePicker
const availableDatesForCalendar = computed(() => {
  if (!service.value?.date) return [];
  return service.value.date.map(d => new Date(d.date + 'T00:00:00'));
});

// Function to disable dates in the calendar
const disabledDates = computed(() => {
  return {
    customDates: (date) => {
      const today = new Date();
      today.setHours(0, 0, 0, 0); // Normalize to midnight
      const currentDate = new Date(date);
      currentDate.setHours(0, 0, 0, 0);

      const isAvailable = availableDatesForCalendar.value.some(availDate =>
        availDate.toDateString() === currentDate.toDateString()
      );

      return !isAvailable || currentDate < today;
    },
  };
});

const formatDate = (dateStr) => {
  if (!dateStr) return '-'
  return new Date(dateStr + 'T00:00:00').toLocaleDateString('id-ID', {
    weekday: 'short',
    day: '2-digit',
    month: 'short',
    year: 'numeric',
  })
}

const formatDateShort = (dateStr) => {
  if (!dateStr) return '-'
  return new Date(dateStr + 'T00:00:00').toLocaleDateString('id-ID', {
    month: 'short',
    day: '2-digit',
  })
}

watch(() => form.value.date, (newDate, oldDate) => {
  // Logic if date changes (optional)
});


onMounted(async () => {
  // --- PERBAIKAN UTAMA: Atur locale setelah DatePicker diimpor ---
  // Ini harus dipanggil sebelum DatePicker digunakan/dirender
  DatePicker.locale(idLocale);

  try {
    await store.fetchServiceById(route.params.id)
    service.value = store.service
    // Ambil review setelah data layanan dimuat
    await store.fetchServiceReviews(route.params.id);
    serviceReviews.value = store.reviews; // Simpan ke ref lokal serviceReviews

    if (service.value && service.value.time && service.value.time.length > 0) {
      // Logic for time options if needed
    }
    if (service.value && service.value.option && service.value.option.length > 0) {
      // Logic for option types if needed
    }
  } catch (err) {
    console.error('Failed to load service or reviews:', err)
    showNotification('error', 'Failed to load service details or reviews. Please try again.');
  } finally {
    isLoadingService.value = false;
  }
})

const submitBooking = async () => {
  if (!form.value.date || !form.value.time || !form.value.option) {
    showNotification('warning', 'Please select a date, time, and meeting method to confirm your booking.');
    return;
  }

  try {
    isSubmitting.value = true;
    const payload = {
      time: form.value.time,
      date: [
        form.value.date.getFullYear(),
        (form.value.date.getMonth() + 1).toString().padStart(2, '0'),
        form.value.date.getDate().toString().padStart(2, '0')
      ].join('-'),
      note: form.value.note,
      option: form.value.option,
    };

    await store.bookService(route.params.id, payload);
    showNotification('success', 'Service booked successfully, awaiting approval.');
    router.push('/client/activity');
  } catch (err) {
    console.error(err);
    const errorMessage = err.response?.data?.message || 'Unfortunately, this service is already booked at that time or an error occurred. Please select another date/time.';
    showNotification('error', errorMessage);
  } finally {
    isSubmitting.value = false;
  }
};
</script>

<template>
  <div class="min-h-screen bg-gray-50 p-4 sm:p-6 lg:p-8 relative">
    <div class="fixed top-4 right-4 z-50 space-y-3">
      <div
        v-for="notification in notifications"
        :key="notification.id"
        :class="[
          'p-4 rounded-lg shadow-md text-white flex items-center justify-between transition-all duration-300 transform',
          {
            'bg-green-500': notification.type === 'success',
            'bg-red-500': notification.type === 'error',
            'bg-yellow-500': notification.type === 'warning',
          }
        ]"
      >
        <span>{{ notification.message }}</span>
        <button @click="removeNotification(notification.id)" class="ml-4 text-white hover:text-gray-100 focus:outline-none">
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
        </button>
      </div>
    </div>

    <div v-if="isLoadingService" class="flex justify-center items-center h-96">
      <div class="animate-spin rounded-full h-12 w-12 border-4 border-indigo-500 border-t-transparent"></div>
      <p class="ml-4 text-gray-600">Loading service details...</p>
    </div>

    <div v-else-if="!service" class="text-center text-gray-500 p-8">
      <p class="text-lg">Service not found.</p>
      <p class="text-sm mt-2">The service you are looking for might not exist or has been removed.</p>
      <button @click="router.push('/client/service')" class="mt-4 inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">
        Browse Services
      </button>
    </div>

    <div v-else class="max-w-6xl mx-auto bg-white rounded-2xl shadow-xl overflow-hidden md:flex">
      <div class="md:w-1/2 p-6 sm:p-8 lg:p-10 bg-gray-50 border-r border-gray-100 flex flex-col justify-between">
        <div>
          <h3 class="text-2xl font-bold text-gray-800 mb-6 flex items-center gap-3">
            <ClipboardEdit class="w-7 h-7 text-indigo-600" /> Confirm Your Booking
          </h3>

          <form @submit.prevent="submitBooking" class="space-y-6">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Select Date</label>
              <DatePicker
                v-model:value="form.date"
                :disabled-date="disabledDates.customDates"
                type="date"
                placeholder="Choose a date"
                format="YYYY-MM-DD"
                value-type="date"
                :clearable="false"
                class="w-full"
                :editable="false"
              >
                <template #icon-calendar>
                  <CalendarDays class="w-5 h-5 text-gray-500" />
                </template>
              </DatePicker>
              <p v-if="form.date && disabledDates.customDates(form.date)" class="text-sm text-red-500 mt-2">
                This date is not available or is in the past. Please select an available date.
              </p>
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Select Time</label>
              <div class="flex flex-wrap gap-3">
                <button
                  v-for="(t, i) in service.time || []"
                  :key="i"
                  type="button"
                  @click="form.time = t"
                  :class="[
                    'px-4 py-2 rounded-full border text-sm font-medium transition-all duration-200 ease-in-out',
                    form.time === t
                      ? 'bg-indigo-600 text-white shadow-md'
                      : 'bg-white text-gray-800 border-gray-300 hover:bg-indigo-50 hover:border-indigo-400'
                  ]"
                >
                  {{ t }}
                </button>
                <p v-if="!service.time || service.time.length === 0" class="text-gray-500 text-sm">No time slots available for this service.</p>
              </div>
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Meeting Method</label>
              <div class="flex flex-wrap gap-3">
                <button
                  v-for="(opt, i) in service.option || []"
                  :key="i"
                  type="button"
                  @click="form.option = opt"
                  :class="[
                    'px-4 py-2 rounded-full border text-sm font-medium transition-all duration-200 ease-in-out',
                    form.option === opt
                      ? 'bg-indigo-600 text-white shadow-md'
                      : 'bg-white text-gray-800 border-gray-300 hover:bg-indigo-50 hover:border-indigo-400'
                  ]"
                >
                  {{ opt }}
                </button>
                  <p v-if="!service.option || service.option.length === 0" class="text-gray-500 text-sm">No options available for this service.</p>
              </div>
            </div>

            <button
              type="submit"
              class="w-full bg-indigo-600 hover:bg-indigo-700 text-white font-semibold py-3 px-4 rounded-lg transition-all duration-200 ease-in-out shadow-md hover:shadow-lg focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 flex items-center justify-center gap-2"
              :disabled="isSubmitting || !form.date || disabledDates.customDates(form.date) || !form.time || !form.option"
            >
              <svg v-if="isSubmitting" class="animate-spin h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
              </svg>
              {{ isSubmitting ? 'Confirming...' : 'Confirm Booking' }}
            </button>
          </form>
        </div>
      </div>

      <div class="md:w-1/2 p-6 sm:p-8 lg:p-10">
        <div class="rounded-xl overflow-hidden mb-6 shadow-md">
          <img
            :src="service.image || fallbackImage"
            :alt="service.title || 'Service Image'"
            class="w-full h-64 object-cover"
          />
        </div>

        <h2 class="text-3xl font-extrabold text-gray-900 mb-3">{{ service.title }}</h2>
        <p class="text-gray-700 text-base leading-relaxed mb-6">{{ service.description }}</p>

        <ReviewSummary :reviews="serviceReviews" @open-all-reviews="openAllReviewsModal" />

        <div class="space-y-4 text-gray-700 text-base">
            <MapPin class="w-5 h-5 text-indigo-600 mt-1" />
            <div>
              <strong class="block text-gray-900">Location:</strong>
              <span class="text-indigo-600 break-all hover:underline">{{ service.location }}</span>
          </div>

          <div class="flex items-start gap-3">
            <ListChecks class="w-5 h-5 text-indigo-600 mt-1" />
            <div>
              <strong class="block text-gray-900">Options:</strong>
              <span>{{ service.option?.join(', ') || 'N/A' }}</span>
            </div>
          </div>

          <div class="flex items-start gap-3">
            <CalendarClock class="w-5 h-5 text-indigo-600 mt-1" />
            <div>
              <strong class="block text-gray-900">Available Days:</strong>
              <span>{{ service.days?.join(', ') || 'N/A' }}</span>
            </div>
          </div>

          <div class="flex items-start gap-3">
            <Clock class="w-5 h-5 text-indigo-600 mt-1" />
            <div>
              <strong class="block text-gray-900">Available Time Slots:</strong>
              <span>{{ service.time?.join(', ') || 'N/A' }}</span>
            </div>
          </div>

          <div class="flex items-start gap-3">
            <CalendarDays class="w-5 h-5 text-indigo-600 mt-1" />
            <div>
              <strong class="block text-gray-900">Date Range:</strong>
              <span>{{ formatDate(service.date?.[0]?.date) }} - {{ formatDate(service.end_date) }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <AllReviewsModal :reviews="serviceReviews" :is-visible="showAllReviewsModal" @close="closeAllReviewsModal" />

  </div>
</template>

<style>
/* Anda bisa mempertahankan bagian style ini seperti sebelumnya */
.mx-datepicker {
  width: 100%;
}

.mx-input {
  display: block;
  width: 100%;
  padding: 0.75rem 1rem;
  font-size: 0.875rem;
  line-height: 1.25rem;
  border: 1px solid #d1d5db;
  border-radius: 0.5rem;
  box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
  transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;
}

.mx-input:focus {
  border-color: #6366f1;
  box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.25);
  outline: none;
}

.mx-icon-calendar {
  right: 12px;
}


.mx-calendar-content .cell.disabled {
  background-color: #f3f4f6 !important;
  color: #9ca3af !important;
  cursor: not-allowed !important;
}

.fixed.top-4.right-4.z-50.space-y-3 > div {
  min-width: 250px;
  max-width: 350px;
}
</style>