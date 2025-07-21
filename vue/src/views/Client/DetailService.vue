<script setup>
import { ref, onMounted, computed, watch, nextTick } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useServiceStore } from '@/stores/service'
import fallbackImage from '@/assets/images/booking.jpg'
import ReviewSummary from '@/components/Client/Review/ReviewSummary.vue';
import AllReviewsModal from '@/components/Client/modals/AllReviewsModal.vue';
import MapModal from '@/components/Client/modals/MapModal.vue';

// Import Vue DatePicker component and its CSS
import DatePicker from 'vue-datepicker-next';
import 'vue-datepicker-next/index.css';

console.log('DatePicker component and CSS imported.');

// Import icons from lucide-vue-next for UI elements
import {
  MapPin,
  ListChecks,
  CalendarClock,
  ClipboardEdit,
  Clock,
  CalendarDays,
  Info, // Import the Info icon (still useful for other info sections)
} from 'lucide-vue-next'

console.log('Lucide icons imported.');

// --- Notification System Setup ---
// Reactive array to hold notification objects
const notifications = ref([]);
// Counter for unique notification IDs
let notificationId = 0;

/**
 * Displays a notification message.
 * @param {string} type - Type of notification (e.g., 'success', 'error', 'warning').
 * @param {string} message - The message to display.
 */
const showNotification = (type, message) => {
  const id = notificationId++;
  notifications.value.push({ id, type, message });
  console.log(`Notification shown: Type=${type}, Message=${message}`);
  // Automatically remove notification after 5 seconds
  setTimeout(() => {
    removeNotification(id);
  }, 5000);
};

/**
 * Removes a notification from the display.
 * @param {number} id - The ID of the notification to remove.
 */
const removeNotification = (id) => {
  notifications.value = notifications.value.filter(n => n.id !== id);
  console.log(`Notification removed: ID=${id}`);
};
// --- End Notification System Setup ---

// Initialize Vue Router and Pinia store
const route = useRoute()
const router = useRouter()
const store = useServiceStore()
// Reactive variables for service data and loading states
const service = ref(null)
const isSubmitting = ref(false)
const isLoadingService = ref(true)

console.log('Vue Router, Pinia store, and reactive refs initialized.');

// Reactive form data for booking
const form = ref({
  date: null, // Stores Date object from calendar
  time: '',
  option: '',
  note: '',
})
console.log('Form data initialized:', form.value);


// === Review Section ===
const serviceReviews = ref([]); // Stores all reviews for the service
const showAllReviewsModal = ref(false); // State for showing/hiding the "All Reviews" modal

const openAllReviewsModal = () => {
  showAllReviewsModal.value = true;
  console.log('All Reviews Modal opened.');
};

const closeAllReviewsModal = () => {
  showAllReviewsModal.value = false;
  console.log('All Reviews Modal closed.');
};
// === End Review Section ===


// === Map Modal Section ===
const showMapModal = ref(false);

const openMapModal = async () => {
  console.log('Attempting to open Map Modal...');
  // Check if service data and coordinates are available before opening map
  if (service.value && service.value.latitude && service.value.longitude) {
    showMapModal.value = true;
    console.log(`Map Modal opened with coordinates: [${service.value.longitude}, ${service.value.latitude}]`);
  } else {
    // Show a warning if location data is missing
    showNotification('warning', 'Location coordinates are not available for this service.');
    console.warn('Map Modal not opened: Missing latitude or longitude for service.', service.value);
  }
};

const closeMapModal = () => {
  showMapModal.value = false;
  console.log('Map Modal closed.');
};
// === End Map Modal Section ===


// Computed property for available dates formatted for DatePicker
const availableDatesForCalendar = computed(() => {
  if (!service.value?.date) {
    console.log('No service dates available for calendar.');
    return [];
  }
  // Convert date strings from service.value.date into Date objects
  const dates = service.value.date.map(d => new Date(d.date + 'T00:00:00'));
  console.log('Available dates for calendar computed:', dates);
  return dates;
});

// Function to disable dates in the calendar (past dates and unavailable dates)
const disabledDates = computed(() => {
  return {
    customDates: (date) => {
      const today = new Date();
      today.setHours(0, 0, 0, 0); // Set to start of today for comparison
      const currentDate = new Date(date);
      currentDate.setHours(0, 0, 0, 0); // Set to start of current date for comparison

      // Check if the current date is one of the available dates for the service
      const isAvailable = availableDatesForCalendar.value.some(availDate =>
        availDate.toDateString() === currentDate.toDateString()
      );
      // Disable if not available or if the date is in the past
      const isDisabled = !isAvailable || currentDate < today;
      return isDisabled;
    },
  };
});

/**
 * Formats a date string into a readable 'en-US' locale format.
 * @param {string} dateStr - The date string to format.
 * @returns {string} - Formatted date string or '-' if null/empty.
 */
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

// REMOVED: New reactive variable for Google Calendar toggle
// const enableGoogleCalendar = ref(false);

// Reactive variable for "More Information" section toggle
const showMoreInformation = ref(false);


// REMOVED: Google Calendar Integration - computed property for URL
/*
const googleCalendarUrl = computed(() => {
  if (!form.value.date || !form.value.time || !service.value) {
    return '';
  }

  const startDate = new Date(form.value.date);
  const [hours, minutes] = form.value.time.split(':').map(Number);
  startDate.setHours(hours, minutes, 0, 0);

  const endDate = new Date(startDate.getTime() + 60 * 60 * 1000);

  const formatDateTime = (date) => {
    return date.toISOString().replace(/[-:]|\.\d{3}/g, '');
  };

  const eventTitle = encodeURIComponent(`Booking: ${service.value.title}`);
  const eventDetails = encodeURIComponent(`Service: ${service.value.title}\nTime: ${form.value.time}\nMeeting Method: ${form.value.option}\nNote: ${form.value.note || 'N/A'}`);
  const eventLocation = encodeURIComponent(service.value.location);
  const dates = `${formatDateTime(startDate)}/${formatDateTime(endDate)}`;

  let calendarUrl = `https://calendar.google.com/calendar/render?action=TEMPLATE&text=${eventTitle}&dates=${dates}&details=${eventDetails}&location=${eventLocation}&sf=true&output=xml`;

  return calendarUrl;
});
*/


// Lifecycle hook: runs after the component is mounted to the DOM
onMounted(async () => {
  console.log('onMounted hook triggered.');
  try {
    isLoadingService.value = true;
    console.log(`Fetching service by ID: ${route.params.id}`);
    // Fetch service details from the store
    await store.fetchServiceById(route.params.id);
    service.value = store.service;
    console.log('Service data fetched:', service.value);

    console.log(`Fetching reviews for service ID: ${route.params.id}`);
    // Fetch reviews for the service
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

/**
 * Handles the booking submission process.
 * Includes validation for form fields.
 */
const submitBooking = async () => {
  console.log('Submit booking initiated. Form data:', form.value);

  // --- Form Validation (Before Submission) ---
  // Check if date, time, or option are not filled
  if (!form.value.date || !form.value.time || !form.value.option) {
    // Display a warning notification if fields are missing
    showNotification('warning', 'Please select a date, time, and meeting method to confirm your booking.');
    console.warn('Booking submission aborted: Missing required fields.');
    return; // Stop the submission process
  }
  // --- End Form Validation ---

  try {
    isSubmitting.value = true; // Set submitting state to true
    // Prepare the payload for the booking API call
    const payload = {
      time: form.value.time,
      date: [
        form.value.date.getFullYear(),
        (form.value.date.getMonth() + 1).toString().padStart(2, '0'), // Month is 0-indexed
        form.value.date.getDate().toString().padStart(2, '0')
      ].join('-'), // Format date as YYYY-MM-DD
      note: form.value.note,
      option: form.value.option,
    };
    console.log('Booking payload:', payload);

    console.log(`Booking service ID ${route.params.id} with payload...`);
    // Call the service booking API
    await store.bookService(route.params.id, payload);
    // Show success notification upon successful booking
    showNotification('success', 'Service booked successfully, awaiting approval.');
    console.log('Booking successful. Redirecting to /client/history');
    // Redirect to the client activity page
    router.push('/client/booking/aktif');

    // REMOVED: Google Calendar opening logic
    /*
    if (enableGoogleCalendar.value) {
      window.open(googleCalendarUrl.value, '_blank');
      console.log('Google Calendar URL opened in new tab.');
    }
    */

  } catch (err) {
    console.error('Booking failed:', err);
    // Determine the error message to display
    const errorMessage = err.response?.data?.message || 'Unfortunately, this service is already booked at that time or an error occurred. Please select another date/time.';
    showNotification('error', errorMessage); // Show error notification
    console.error('Displaying booking error message:', errorMessage);
  } finally {
    isSubmitting.value = false; // Reset submitting state
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

            <button
              type="submit"
              class="w-full bg-indigo-600 hover:bg-indigo-700 text-white font-semibold py-3 px-4 rounded-lg transition-all duration-200 ease-in-out shadow-md hover:shadow-lg focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 flex items-center justify-center gap-2"
              :disabled="isSubmitting || !form.date || disabledDates.customDates(form.date) || !form.time || !form.option"
              @click="submitBooking"
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