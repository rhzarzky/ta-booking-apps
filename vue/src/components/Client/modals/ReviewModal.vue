<script setup>
import { ref, watch } from 'vue';
import { useBookingStore } from '@/stores/booking';


const props = defineProps({
  show: {
    type: Boolean,
    default: false,
  },
  serviceId: { // ID layanan yang akan direview (bukan bookingId lagi)
    type: Number,
    required: null, // Ubah menjadi null atau 0 jika serviceId bisa kosong
  },
});

const emit = defineEmits(['close', 'review-submitted']); // Event yang dipancarkan

const bookingStore = useBookingStore();
// const authStore = useAuthStore(); // Contoh: inisialisasi auth store

const rating = ref(0);
const comment = ref('');
const submitting = ref(false);
const errorMessage = ref('');

// Watch `show` prop untuk mereset form ketika modal dibuka
watch(() => props.show, (newVal) => {
  if (newVal) {
    rating.value = 0;
    comment.value = '';
    errorMessage.value = '';
  }
});

const submitReview = async () => {
  errorMessage.value = ''; // Reset error message
  if (rating.value === 0) {
    errorMessage.value = 'Mohon berikan rating (minimal 1 bintang).';
    return;
  }
  if (!props.serviceId) { // Menggunakan serviceId
    errorMessage.value = 'ID Layanan tidak ditemukan. Tidak dapat mengirim review.';
    return;
  }

  submitting.value = true;
  try {
    const reviewData = {
      rating: rating.value,
      comment: comment.value,
    };
    // Menggunakan serviceId untuk submit review
    await bookingStore.submitReview(props.serviceId, reviewData);
    emit('review-submitted');
    emit('close');
  } catch (error) {
    console.error('Error submitting review:', error);
    errorMessage.value = error.response?.data?.message || 'Gagal mengirim review. Silakan coba lagi.';
  } finally {
    submitting.value = false;
  }
};

const closeModal = () => {
  emit('close');
};
</script>

<template>
  <div v-if="show" class="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50">
    <div class="bg-white rounded-lg shadow-xl p-6 w-full max-w-md mx-auto">
      <h2 class="text-2xl font-bold text-gray-800 mb-4">Leave your review</h2>
      <p class="text-sm text-gray-600 mb-4">Please rate and comment on this service.</p>

      <div class="mb-4">
        <label class="block text-gray-700 text-sm font-bold mb-2">Rating:</label>
        <div class="flex items-center space-x-1">
          <template v-for="star in 5" :key="star">
            <svg
              @click="rating = star"
              :class="{ 'text-yellow-400': rating >= star, 'text-gray-300': rating < star }"
              class="w-8 h-8 cursor-pointer transition-colors duration-200"
              fill="currentColor"
              viewBox="0 0 20 20"
            >
              <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.538 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.783.57-1.838-.197-1.538-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.92 8.72c-.783-.57-.381-1.81.588-1.81h3.462a1 1 0 00.95-.69l1.07-3.292z"></path>
            </svg>
          </template>
        </div>
        <p v-if="rating > 0" class="text-sm text-gray-500 mt-1">You provide {{ rating }} star.</p>
      </div>

      <div class="mb-6">
        <label for="comment" class="block text-gray-700 text-sm font-bold mb-2">Comment:</label>
        <textarea
          id="comment"
          v-model="comment"
          rows="4"
          placeholder="Write your comments here..."
          class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline focus:ring-blue-500 focus:border-blue-500"
        ></textarea>
      </div>

      <p v-if="errorMessage" class="text-red-500 text-sm mb-4">{{ errorMessage }}</p>

      <div class="flex justify-end space-x-3">
        <button
          @click="closeModal"
          type="button"
          class="bg-gray-300 hover:bg-gray-400 text-gray-800 font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline"
        >
          Cancel
        </button>
        <button
          @click="submitReview"
          type="submit"
          :disabled="submitting"
          class="bg-blue-600 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline disabled:opacity-50 disabled:cursor-not-allowed"
        >
          <span v-if="submitting">Sending...</span>
          <span v-else>Submit Review</span>
        </button>
      </div>
    </div>
  </div>
</template>