<script setup>
import { defineProps, computed } from 'vue';
import { Star } from 'lucide-vue-next'; // Impor ikon bintang

const props = defineProps({
  review: {
    type: Object,
    required: true,
    validator: (value) => {
      return (
        typeof value.id === 'number' &&
        typeof value.user === 'object' &&
        typeof value.user.name === 'string' &&
        typeof value.rating === 'number' &&
        typeof value.created_at === 'string'
      );
    },
  },
});

// Fungsi untuk merender ikon bintang berdasarkan rating
const renderStars = (rating) => {
  const fullStars = Math.floor(rating);
  const halfStar = rating % 1 >= 0.5;
  const emptyStars = 5 - fullStars - (halfStar ? 1 : 0);
  return { fullStars, halfStar, emptyStars };
};

// Fungsi untuk memformat tanggal review agar lebih mudah dibaca (misal: "3 hari lalu")
const formatReviewDate = (dateStr) => {
    if (!dateStr) return '';
    // Mengganti format DD-MM-YYYY HH:mm:ss menjadi YYYY/MM/DD HH:mm:ss untuk kompatibilitas Date()
    const parts = dateStr.split(/[\s-:]/);
    // Asumsi parts[0]=DD, parts[1]=MM, parts[2]=YYYY, parts[3]=HH, parts[4]=mm, parts[5]=ss
    const formattedDateStr = `${parts[2]}/${parts[1]}/${parts[0]} ${parts[3]}:${parts[4]}:${parts[5]}`;
    const date = new Date(formattedDateStr);
    const now = new Date();
    const diffMs = Math.abs(now - date); // Selisih dalam milidetik

    const seconds = Math.floor(diffMs / 1000);
    const minutes = Math.floor(seconds / 60);
    const hours = Math.floor(minutes / 60);
    const days = Math.floor(hours / 24);
    const months = Math.floor(days / 30.437); // Rata-rata hari dalam sebulan
    const years = Math.floor(days / 365.25); // Rata-rata hari dalam setahun (termasuk tahun kabisat)

    if (seconds < 60) return 'Baru saja';
    if (minutes < 60) return `${minutes} menit lalu`;
    if (hours < 24) return `${hours} jam lalu`;
    if (days === 1) return 'Kemarin';
    if (days < 30) return `${days} hari lalu`;
    if (months === 1) return '1 bulan lalu';
    if (months < 12) return `${Math.floor(months)} bulan lalu`;
    if (years === 1) return '1 tahun lalu';
    return `${Math.floor(years)} tahun lalu`;
};
</script>

<template>
  <div class="p-3 bg-gray-50 rounded-lg shadow-sm">
    <div class="flex items-center justify-between mb-1">
      <span class="font-semibold text-gray-800">{{ review.user.name }}</span>
    </div>
    <div class="flex items-center mb-2">
      <template v-for="n in renderStars(review.rating).fullStars" :key="'full-rev-' + review.id + '-' + n">
        <Star class="w-4 h-4 text-yellow-400 fill-current" />
      </template>
      <template v-if="renderStars(review.rating).halfStar">
        <Star class="w-4 h-4 text-yellow-400 fill-current" style="clip-path: inset(0 50% 0 0);" />
      </template>
      <template v-for="n in renderStars(review.rating).emptyStars" :key="'empty-rev-' + review.id + '-' + n">
        <Star class="w-4 h-4 text-gray-300" />
      </template>
    </div>
    <p v-if="review.comment" class="text-gray-700 text-sm">{{ review.comment }}</p>
    <p v-else class="text-gray-500 text-sm italic">Tidak ada komentar.</p>
  </div>
</template>