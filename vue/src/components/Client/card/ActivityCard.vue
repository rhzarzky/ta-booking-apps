<script setup>
import fallbackImage from '@/assets/images/booking.jpg';
import { useRouter } from 'vue-router';
import { computed } from 'vue'; // Hapus onMounted, watch, ref karena tidak lagi fetch di sini
import { useBookingStore } from '@/stores/booking'; // bookingStore tetap dibutuhkan untuk completeBooking

const props = defineProps({
  booking: {
    type: Object,
    required: true
  },
  // Prop baru untuk menerima data status tambahan yang sudah di-fetch oleh Activity.vue
  extraStatusData: {
    type: Object,
    default: () => ({ completionStatus: null, canReview: false, localReview: null })
  }
});

// Emit event untuk memberitahu parent (Activity.vue) saat ada perubahan status
const emit = defineEmits(['go-to-review-form', 'booking-status-updated']);

const router = useRouter();
const bookingStore = useBookingStore();

// Gunakan computed properties untuk mengakses data dari props.extraStatusData
const localCompletionStatus = computed(() => props.extraStatusData.completionStatus);
const localCanReview = computed(() => props.extraStatusData.canReview);
const localReview = computed(() => props.extraStatusData.localReview);

const goToDetail = () => {
  router.push({
    name: 'client-detail-booking',
    params: {
      id: props.booking.id_booking
    }
  });
};

const triggerReviewForm = () => {
  emit('go-to-review-form', props.booking.id_booking);
};

const formatDate = (dateStr) => {
  if (!dateStr) return '-';
  const options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' };
  try {
    return new Date(dateStr).toLocaleDateString('id-ID', options);
  } catch (e) {
    console.error("Invalid date string for formatDate:", dateStr, e);
    return dateStr;
  }
};

const formatTime = (timeStr) => {
  if (!timeStr) return '-';
  const [hour, minute] = timeStr.split(':');
  return `${hour}:${minute}`;
};

/**
 * Menghitung status tampilan final untuk booking ini.
 * Logika ini harus konsisten dengan getDisplayStatusForBooking di Activity.vue.
 */
const displayStatus = computed(() => {
  const currentMainStatus = (props.booking?.status || '').toLowerCase();
  const currentCompletionStatus = (localCompletionStatus.value || '').toLowerCase();

  // Prioritas untuk status kustom Anda
  if (localReview.value) { // Jika ada review yang sudah disubmit
    return 'Completed'; // Ganti dengan "Completed" jika sudah direview
  } else if (currentCompletionStatus === 'completed - awaiting review' && localCanReview.value) {
    return 'Menunggu Review'; // Jika status completion adalah ini dan bisa direview
  } else if (currentCompletionStatus === 'declined review') {
    return 'Declined'; // Jika status completion adalah declined review
  } else if (currentMainStatus === 'approved') {
    return 'Approved'; // Jika status utama Approved
  } else if (currentMainStatus === 'pending') {
    return 'Pending'; // Jika status utama Pending atau Menunggu Pembayaran
  } else if (currentMainStatus === 'declined') {
    return 'Declined'; // Jika status utama Declined
  }
  
  // Default fallback
  return currentMainStatus || '-';
});

const statusClass = computed(() => {
  const statusToClassify = displayStatus.value.toLowerCase(); // Gunakan displayStatus untuk klasifikasi warna

  switch (statusToClassify) {
    case 'pending':
      return 'bg-lime-100 text-lime-700'; // Warna untuk Pending
    case 'approved':
      return 'bg-purple-100 text-purple-700'; // Warna untuk Approved
    case 'menunggu review':
      return 'bg-yellow-100 text-yellow-700'; // Warna untuk Menunggu Review
    case 'completed':
      return 'bg-green-100 text-green-700'; // Warna untuk Completed (sudah direview)
    case 'declined':
      return 'bg-red-100 text-red-700'; // Warna untuk Declined
    default:
      return 'bg-gray-100 text-gray-700';
  }
});

const completeBooking = async () => {
  try {
    const response = await bookingStore.completeBooking(props.booking.id_booking);
    
    if (response.data && response.data.completion_status) {
        console.log(`[ActivityCard - ${props.booking.id_booking}] completeBooking success. Emitting status updated.`);
        // Beritahu Activity.vue bahwa status booking ini telah berubah
        emit('booking-status-updated'); 
    }
  } catch (error) {
    console.error(`[ActivityCard - ${props.booking.id_booking}] Error completing booking:`, error);
  }
};

// Hapus onMounted dan watch karena ActivityCard tidak lagi melakukan fetch API spesifik
// onMounted(() => {});
// watch(() => props.booking, (newVal, oldVal) => {}, { deep: true });
</script>

<template>
  <div class="bg-white rounded-lg shadow p-4 mb-4">
    <div class="flex items-start gap-4">
      <img
        :src="booking.service?.image || fallbackImage"
        alt="Booking"
        class="w-28 h-28 rounded object-cover"
      />

      <div class="flex-1">
        <div class="flex justify-between items-start">
          <div class="w-full">
            <h2 class="text-xl font-semibold text-gray-800 mb-1">
              {{ booking.service?.title || '-' }}
            </h2>
            <p class="text-sm text-gray-600 mb-3">
              {{ booking.service?.description || '-' }}
            </p>

            <div class="text-sm text-gray-700 space-y-1">
              <p><strong>Date:</strong> {{ formatDate(booking.date) }}</p>
              <p><strong>Time:</strong> {{ formatTime(booking.time) }}</p>
              <p><strong>Option:</strong> {{ booking.option || '-' }}</p>
            </div>

            <div v-if="booking.note" class="text-xs text-gray-500 mt-2">
              <strong>Note:</strong> {{ booking.note }}
            </div>
          </div>

          <span
            class="text-xs px-2 py-1 rounded h-fit ml-2 whitespace-nowrap"
            :class="statusClass"
          >
            {{ displayStatus }} </span>
        </div>

        <div class="mt-3 flex flex-wrap items-center gap-4">
          <button
            @click="goToDetail"
            class="text-sm text-indigo-600 hover:underline"
          >
            View detail booking
          </button>

          <button
            v-if="props.booking.status === 'Approved' && !localReview && localCompletionStatus !== 'Completed - Awaiting Review' && localCompletionStatus !== 'Completed' && localCompletionStatus !== 'Reviewed' && localCompletionStatus !== 'Declined Review'"
            @click="completeBooking"
            class="text-sm text-green-600 hover:underline"
          >
            Selesaikan Booking
          </button>

          <button
            v-if="displayStatus === 'Menunggu Review' && localCanReview && !localReview"
            @click="triggerReviewForm"
            class="text-sm text-yellow-600 hover:underline"
          >
            Tulis Review
          </button>

          <div v-if="['Menunggu Review', 'Completed', 'Declined'].includes(displayStatus)">
            <div v-if="localReview" class="text-sm text-gray-600">
              <strong>Review Anda:</strong> "{{ localReview.comment }}" (Rating: {{ localReview.rating }}/5)
              <p class="text-xs text-gray-500">Direview pada: {{ formatDate(localReview.reviewed_at) }}</p>
            </div>
            <div v-else-if="displayStatus === 'Menunggu Review'" class="text-sm text-blue-600">
              Menunggu Review (Batas waktu: {{ formatDate(booking.review?.review_deadline) || 'Tidak ada batas waktu' }})
            </div>
            <div v-else-if="displayStatus === 'Declined'" class="text-sm text-red-600">
              Booking Ditolak atau Review Kadaluarsa.
            </div>
            <div v-else class="text-sm text-gray-500">
              Status tidak diketahui.
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>