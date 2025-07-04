<script setup>
import { defineProps, defineEmits, computed } from 'vue';
import { Star } from 'lucide-vue-next';
import ReviewCard from '../card/ReviewCard.vue'; // Impor ReviewCard

const props = defineProps({
  reviews: {
    type: Array,
    default: () => [],
  },
});

const emits = defineEmits(['open-all-reviews']);

// Computed property untuk rating rata-rata
const averageRating = computed(() => {
  if (!props.reviews || props.reviews.length === 0) {
    return 0;
  }
  const totalRating = props.reviews.reduce((sum, review) => sum + review.rating, 0);
  return (totalRating / props.reviews.length).toFixed(1);
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

// Computed property untuk 3 review terbaru
const latestReviews = computed(() => {
  return [...props.reviews]
    .sort((a, b) => {
        // Konversi string tanggal ke objek Date untuk perbandingan
        const dateA = new Date(a.created_at.replace(/-/g, '/').replace(' ', 'T'));
        const dateB = new Date(b.created_at.replace(/-/g, '/').replace(' ', 'T'));
        return dateB - dateA;
    })
    .slice(0, 2);
});

const handleOpenAllReviews = () => {
  emits('open-all-reviews');
};
</script>

<template>
  <div class="mb-6 pb-4 border-b border-gray-200">
    <h3 class="text-xl font-bold text-gray-800 mb-3">Rating & Ulasan</h3>
    <div v-if="totalReviews > 0">
      <div class="flex items-center gap-2 mb-4">
        <span class="text-3xl font-semibold text-gray-900">{{ averageRating }}</span>
        <div class="flex items-center">
          <template v-for="n in renderStars(averageRating).fullStars" :key="'full-avg-' + n">
            <Star class="w-5 h-5 text-yellow-400 fill-current" />
          </template>
          <template v-if="renderStars(averageRating).halfStar">
            <Star class="w-5 h-5 text-yellow-400 fill-current" style="clip-path: inset(0 50% 0 0);" />
          </template>
          <template v-for="n in renderStars(averageRating).emptyStars" :key="'empty-avg-' + n">
            <Star class="w-5 h-5 text-gray-300" />
          </template>
        </div>
        <span class="text-gray-600">({{ totalReviews }} ulasan)</span>
      </div>

      <div class="space-y-4">
        <ReviewCard v-for="review in latestReviews" :key="review.id" :review="review" />
      </div>

      <button
        v-if="totalReviews > 0"
        @click="handleOpenAllReviews"
        class="mt-4 text-indigo-600 hover:text-indigo-800 font-medium text-sm inline-flex items-center"
      >
        Lihat Semua {{ totalReviews }} Ulasan
        <svg class="ml-1 w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"></path></svg>
      </button>
    </div>
    <div v-else class="text-gray-500">Belum ada ulasan untuk layanan ini.</div>
  </div>
</template>