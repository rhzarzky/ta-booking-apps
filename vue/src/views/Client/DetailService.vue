<script setup>
import { ref, onMounted, computed, watch, nextTick } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useServiceStore } from '@/stores/service'
import fallbackImage from '@/assets/images/booking.jpg'
import ReviewSummary from '@/components/Client/Review/ReviewSummary.vue';
import AllReviewsModal from '@/components/Client/modals/AllReviewsModal.vue';
import MapModal from '@/components/Client/modals/MapModal.vue';

import DatePicker from 'vue-datepicker-next';
import 'vue-datepicker-next/index.css';

console.log('DatePicker component and CSS imported.');

// Import icons from lucide-vue-next
import {
  MapPin,
  ListChecks,
  CalendarClock,
  ClipboardEdit,
  Clock,
  CalendarDays,
  Info, // Import the Info icon
} from 'lucide-vue-next'

console.log('Lucide icons imported.');

// --- Notification System Setup ---
const notifications = ref([]);
let notificationId = 0;

const showNotification = (type, message) => {
  const id = notificationId++;
  notifications.value.push({ id, type, message });
  console.log(`Notification shown: Type=${type}, Message=${message}`);
  setTimeout(() => {
    removeNotification(id);
  }, 5000); // Notifications disappear after 5 seconds
};

const removeNotification = (id) => {
  notifications.value = notifications.value.filter(n => n.id !== id);
  console.log(`Notification removed: ID=${id}`);
};
// --- End Notification System Setup ---

const route = useRoute()
const router = useRouter()
const store = useServiceStore()
const service = ref(null)
const isSubmitting = ref(false)
const isLoadingService = ref(true)

console.log('Vue Router, Pinia store, and reactive refs initialized.');

const form = ref({
  date: null, // Will store Date object from calendar
  time: '',
  option: '',
  note: '',
})
console.log('Form data initialized:', form.value);


// === Bagian untuk Review ===
const serviceReviews = ref([]); // Menyimpan semua review
const showAllReviewsModal = ref(false); // State untuk menampilkan/menyembunyikan modal

const openAllReviewsModal = () => {
  showAllReviewsModal.value = true;
  console.log('All Reviews Modal opened.');
};

const closeAllReviewsModal = () => {
  showAllReviewsModal.value = false;
  console.log('All Reviews Modal closed.');
};
// === Akhir Bagian untuk Review ===


// === Bagian untuk Modal Peta ===
const showMapModal = ref(false);

const openMapModal = async () => {
  console.log('Attempting to open Map Modal...');
  if (service.value && service.value.latitude && service.value.longitude) {
    showMapModal.value = true;
    console.log(`Map Modal opened with coordinates: [${service.value.longitude}, ${service.value.latitude}]`);
  } else {
    showNotification('warning', 'Location coordinates are not available for this service.');
    console.warn('Map Modal not opened: Missing latitude or longitude for service.', service.value);
  }
};

const closeMapModal = () => {
  showMapModal.value = false;
  console.log('Map Modal closed.');
};
// === Akhir Bagian untuk Modal Peta ===


// Computed property for available dates formatted for DatePicker
const availableDatesForCalendar = computed(() => {
  if (!service.value?.date) {
    console.log('No service dates available for calendar.');
    return [];
  }
  const dates = service.value.date.map(d => new Date(d.date + 'T00:00:00'));
  console.log('Available dates for calendar computed:', dates);
  return dates;
});

// Function to disable dates in the calendar
const disabledDates = computed(() => {
  return {
    customDates: (date) => {
      const today = new Date();
      today.setHours(0, 0, 0, 0);
      const currentDate = new Date(date);
      currentDate.setHours(0, 0, 0, 0);

      const isAvailable = availableDatesForCalendar.value.some(availDate =>
        availDate.toDateString() === currentDate.toDateString()
      );
      const isDisabled = !isAvailable || currentDate < today;
      return isDisabled;
    },
  };
});

const formatDate = (dateStr) => {
  if (!dateStr) return '-'
  // Changed locale to 'en-US' for English formatting
  const formatted = new Date(dateStr + 'T00:00:00').toLocaleDateString('en-US', {
    weekday: 'short',
    day: '2-digit',
    month: 'short',
    year: 'numeric',
  });
  console.log(`Formatted date "${dateStr}" to "${formatted}" (en-US)`);
  return formatted;
}

// New reactive variable for Google Calendar toggle
const enableGoogleCalendar = ref(false);
// New reactive variable for "More Information" toggle
const showMoreInformation = ref(false);


// Computed property to generate Google Calendar URL
const googleCalendarUrl = computed(() => {
  if (!form.value.date || !form.value.time || !service.value) {
    return '';
  }

  const startDate = new Date(form.value.date);
  const [hours, minutes] = form.value.time.split(':').map(Number);
  startDate.setHours(hours, minutes, 0, 0);

  // Assuming the service lasts for 1 hour for calendar event. Adjust as needed.
  const endDate = new Date(startDate.getTime() + 60 * 60 * 1000);

  const formatDateTime = (date) => {
    return date.toISOString().replace(/[-:]|\.\d{3}/g, '');
  };

  const eventTitle = encodeURIComponent(`Booking: ${service.value.title}`);
  // Updated event details to English
  const eventDetails = encodeURIComponent(`Service: ${service.value.title}\nTime: ${form.value.time}\nMeeting Method: ${form.value.option}\nNote: ${form.value.note || 'N/A'}`);
  const eventLocation = encodeURIComponent(service.value.location);
  const dates = `${formatDateTime(startDate)}/${formatDateTime(endDate)}`;

  let calendarUrl = `https://calendar.google.com/calendar/render?action=TEMPLATE&text=${eventTitle}&dates=${dates}&details=${eventDetails}&location=${eventLocation}&sf=true&output=xml`;

  return calendarUrl;
});


onMounted(async () => {
  console.log('onMounted hook triggered.');
  try {
    isLoadingService.value = true;
    console.log(`Fetching service by ID: ${route.params.id}`);
    await store.fetchServiceById(route.params.id);
    service.value = store.service;
    console.log('Service data fetched:', service.value);

    console.log(`Fetching reviews for service ID: ${route.params.id}`);
    await store.fetchServiceReviews(route.params.id);
    serviceReviews.value = store.reviews;
    console.log('Service reviews fetched:', serviceReviews.value);

    if (service.value) {
      console.log('Service time options:', service.value.time);
      console.log('Service meeting options:', service.value.option);
    }

  } catch (err) {
    console.error('Failed to load service or reviews:', err);
    showNotification('error', 'Failed to load service details or reviews. Please try again.');
  } finally {
    isLoadingService.value = false;
    console.log('Service loading finished. isLoadingService:', isLoadingService.value);
  }
})

const submitBooking = async () => {
  console.log('Submit booking initiated. Form data:', form.value);
  if (!form.value.date || !form.value.time || !form.value.option) {
    // Notification message translated
    showNotification('warning', 'Please select a date, time, and meeting method to confirm your booking.');
    console.warn('Booking submission aborted: Missing required fields.');
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
    console.log('Booking payload:', payload);

    console.log(`Booking service ID ${route.params.id} with payload...`);
    await store.bookService(route.params.id, payload);
    // Notification message translated
    showNotification('success', 'Service booked successfully, awaiting approval.');
    console.log('Booking successful. Redirecting to /client/activity');
    router.push('/client/activity');

    if (enableGoogleCalendar.value) {
      window.open(googleCalendarUrl.value, '_blank');
    }

  } catch (err) {
    console.error('Booking failed:', err);
    // Error message translated
    const errorMessage = err.response?.data?.message || 'Unfortunately, this service is already booked at that time or an error occurred. Please select another date/time.';
    showNotification('error', errorMessage);
    console.error('Displaying booking error message:', errorMessage);
  } finally {
    isSubmitting.value = false;
    console.log('Booking submission process finished. isSubmitting:', isSubmitting.value);
  }
};

console.log('--- Script Setup End ---');
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
  format="YYYY-MM-DD"
  value-type="date"
  :clearable="false"
  :editable="false"
  class="w-full"
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

            <div class="border-t border-gray-200 pt-6">
                <div class="flex items-center justify-between mb-2">
                    <div class="flex items-center gap-2">
                        <svg class="w-6 h-6 text-gray-700" fill="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                          <path d="M19 4h-1V2h-2v2H8V2H6v2H5c-1.11 0-1.99.9-1.99 2L3 20c0 1.1.89 2 2 2h14c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2zm0 16H5V9h14v11zM5 7V6h14v1H5z"/>
                        </svg>
                        <span class="text-lg font-semibold text-gray-800">Google Calendar</span>
                    </div>
                    <label class="relative inline-flex items-center cursor-pointer">
                        <input
                            type="checkbox"
                            v-model="enableGoogleCalendar"
                            class="sr-only peer"
                            :disabled="!form.date || !form.time || !form.option || isSubmitting"
                        >
                        <div
                            class="w-11 h-6 bg-gray-200 rounded-full peer peer-focus:ring-4 peer-focus:ring-indigo-300 dark:peer-focus:ring-indigo-800 dark:bg-gray-700 peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-0.5 after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-indigo-600"
                        ></div>
                    </label>
                </div>
                <p class="text-sm text-gray-600 mb-4">Automatically add this appointment to Google Calendar with reminders.</p>

                <div v-if="enableGoogleCalendar" class="bg-indigo-50 border border-indigo-200 text-indigo-800 p-4 rounded-lg flex items-start gap-3 transition-all duration-300 ease-in-out transform scale-100 opacity-100"
                     :class="{'scale-95 opacity-0': !enableGoogleCalendar}">
                    <Info class="w-5 h-5 flex-shrink-0 mt-0.5" />
                    <div>
                        <ul class="list-disc pl-5 text-sm space-y-1">
                            <li>Reminder 30 minutes before appointment</li>
                            <li>Location details and notes will be included</li>
                        </ul>
                    </div>
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

        <div class="mt-6 border-t border-gray-200 pt-6">
          <button @click="showMoreInformation = !showMoreInformation" class="w-full text-left text-indigo-600 hover:underline font-semibold py-2 px-0 focus:outline-none flex justify-between items-center">
            <span>{{ showMoreInformation ? 'Hide Details' : 'More Information' }}</span>
            <svg :class="{'rotate-180': showMoreInformation}" class="w-5 h-5 transform transition-transform duration-200" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path></svg>
          </button>

          <div v-if="showMoreInformation" class="space-y-4 text-gray-700 text-base mt-4 transition-all duration-300 ease-in-out overflow-hidden"
               :class="{'max-h-0 opacity-0': !showMoreInformation, 'max-h-screen opacity-100': showMoreInformation}">
            <div class="flex items-start gap-3 cursor-pointer" @click="openMapModal">
              <MapPin class="w-5 h-5 text-indigo-600 mt-1" />
              <div>
                <strong class="block text-gray-900">Location:</strong>
                <span class="text-indigo-600 break-all hover:underline">{{ service.location }}</span>
              </div>
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
    </div>

    <AllReviewsModal :reviews="serviceReviews" :is-visible="showAllReviewsModal" @close="closeAllReviewsModal" />

    <MapModal
      :is-visible="showMapModal"
      :location-name="service?.location"
      :coordinates="service ? [service.longitude, service.latitude] : []"
      :service-title="service?.title"
      @close="closeMapModal"
    />

  </div>
</template>

<style>
/* Your existing CSS here... */

/* Styles for the toggle switch */
.sr-only {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap;
  border-width: 0;
}

/* Add transition for the "More Information" section */
.transition-all {
    transition-property: all;
    transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
    transition-duration: 150ms;
}
.duration-300 {
    transition-duration: 300ms;
}
.ease-in-out {
    transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
}
.max-h-0 {
    max-height: 0;
}
.max-h-screen {
    max-height: 100vh; /* Adjust as needed, sufficiently large value */
}
.opacity-0 {
    opacity: 0;
}
.opacity-100 {
    opacity: 1;
}

</style>