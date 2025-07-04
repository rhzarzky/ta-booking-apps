<script setup>
import { defineProps, defineEmits, computed } from 'vue';
import { X, Star } from 'lucide-vue-next'; // Impor ikon 'X' dan 'Star'
import ReviewCard from '../card/ReviewCard.vue';

const props = defineProps({
  reviews: {
    type: Array,
    default: () => [],
  },
  isVisible: {
    type: Boolean,
    required: true,
  },
});

const emits = defineEmits(['close']);

const closeModal = () => {
  emits('close');
};

// Computed property untuk rating rata-rata (disalin dari ReviewSummary atau bisa juga dilewatkan sebagai prop)
const averageRating = computed(() => {
  if (!props.reviews || props.reviews.length === 0) {
    return 0;
  }
  const totalRating = props.reviews.reduce((sum, review) => sum + review.rating, 0);
  return (totalRating / props.reviews.length).toFixed(1); // Satu desimal
});

// Computed property untuk jumlah review
const totalReviews = computed(() => {
  return props.reviews.length;
});

// Fungsi untuk merender ikon bintang
const renderStars = (rating) => {
  const fullStars = Math.floor(rating);
  const halfStar = rating % 1 >= 0.5;
  const emptyStars = 5 - fullStars - (halfStar ? 1 : 0);
  return { fullStars, halfStar, emptyStars };
};

// NEW: Computed property untuk distribusi rating
const ratingDistribution = computed(() => {
  const counts = { 5: 0, 4: 0, 3: 0, 2: 0, 1: 0 };
  props.reviews.forEach(review => {
    if (review.rating >= 1 && review.rating <= 5) {
      counts[review.rating]++;
    }
  });

  const total = props.reviews.length;
  const distribution = {};
  for (let i = 5; i >= 1; i--) {
    distribution[i] = {
      count: counts[i],
      percentage: total > 0 ? (counts[i] / total) * 100 : 0,
    };
  }
  return distribution;
});
</script>

<template>
  <div v-if="isVisible" class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black bg-opacity-50 transition-opacity duration-300">
    <div
      class="bg-white rounded-lg shadow-xl w-full max-w-lg max-h-[90vh] overflow-y-auto transform transition-transform duration-300"
      :class="{ 'scale-100 opacity-100': isVisible, 'scale-95 opacity-0': !isVisible }"
      @click.stop >
      <div class="flex justify-between items-center p-5 border-b border-gray-200">
        <h3 class="text-xl font-bold text-gray-800">All Reviews ({{ reviews.length }})</h3>
        <button @click="closeModal" class="text-gray-500 hover:text-gray-700 p-1 rounded-full focus:outline-none focus:ring-2 focus:ring-gray-300">
          <X class="w-6 h-6" />
        </button>
      </div>

      <div class="p-5 border-b border-gray-200 text-center">
        <h4 class="text-lg font-bold text-gray-800 mb-4">Rating overview</h4>
        <div class="mb-4">
          <span class="text-5xl font-extrabold text-gray-900">{{ averageRating }}</span>
          <span class="text-xl text-gray-600">/5</span>
        </div>
        <div class="flex justify-center items-center mb-2">
          <template v-for="n in renderStars(averageRating).fullStars" :key="'overview-full-' + n">
            <Star class="w-7 h-7 text-yellow-400 fill-current" />
          </template>
          <template v-if="renderStars(averageRating).halfStar">
            <Star class="w-7 h-7 text-yellow-400 fill-current" style="clip-path: inset(0 50% 0 0);" />
          </template>
          <template v-for="n in renderStars(averageRating).emptyStars" :key="'overview-empty-' + n">
            <Star class="w-7 h-7 text-gray-300" />
          </template>
        </div>
        <p class="text-gray-600 text-sm mb-6">{{ totalReviews }} ratings</p>

        <div class="space-y-2">
          <div v-for="n in 5" :key="n" class="flex items-center gap-3">
            <span class="text-sm font-medium text-gray-700 w-8 text-right">{{ 6 - n }} <Star class="w-3 h-3 inline-block text-gray-700" /></span>
            <div class="w-full bg-gray-200 rounded-full h-2.5">
              <div
                class="bg-yellow-400 h-2.5 rounded-full"
                :style="{ width: ratingDistribution[6 - n]?.percentage + '%' }"
              ></div>
            </div>
            <span class="text-sm text-gray-600 w-10 text-left">{{ ratingDistribution[6 - n]?.count }}</span>
          </div>
        </div>
      </div>
      <div class="p-5 space-y-5">
        <ReviewCard v-for="review in reviews" :key="review.id" :review="review" />
        <div v-if="reviews.length === 0" class="text-gray-500 text-center py-5">
          No reviews.
        </div>
      </div>
    </div>
  </div>
</template>