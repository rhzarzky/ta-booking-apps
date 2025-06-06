<template>
  <div class="bg-white rounded-xl shadow-md overflow-hidden transform hover:scale-102 transition duration-300 ease-in-out">
    <div class="relative">
      <img :src="image" alt="Service" class="h-48 w-full object-cover" />
      <button
        @click.stop="toggleBookmark"
        :class="[
          'absolute top-3 right-3 p-2 rounded-full bg-white transition duration-300',
          isServiceBookmarked ? 'text-red-500' : 'text-gray-400 hover:text-red-400'
        ]"
        aria-label="Bookmark service"
      >
        <svg
          v-if="isServiceBookmarked"
          class="w-6 h-6 fill-current"
          xmlns="http://www.w3.org/2000/svg"
          viewBox="0 0 24 24"
        >
          <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/>
        </svg>
        <svg
          v-else
          class="w-6 h-6 fill-current"
          xmlns="http://www.w3.org/2000/svg"
          viewBox="0 0 24 24"
        >
          <path d="M16.5 3c-1.74 0-3.41.81-4.5 2.09C10.91 3.81 9.24 3 7.5 3 4.42 3 2 5.42 2 8.5c0 3.78 3.4 6.86 8.55 11.54L12 21.35l1.45-1.32C18.6 15.36 22 12.28 22 8.5c0-3.08-2.42-5.5-5.5-5.5zm-4.5 16.54l-7.39-6.73C4.25 10.76 4 9.28 4 8.5c0-2.07 1.47-3.5 3.5-3.5 1.41 0 2.75.58 3.75 1.63L12 7.84l.25-.27c1-1.05 2.34-1.63 3.75-1.63C18.53 5 20 6.43 20 8.5c0 .78-.25 2.26-2.61 4.51L12 19.54z"/>
        </svg>
      </button>
    </div>

    <div class="p-5">
      <h2 class="text-xl font-bold text-gray-900 mb-2 truncate">{{ title }}</h2>
      <p class="text-sm text-gray-600 mb-3 line-clamp-2">{{ description }}</p>

      <div class="flex justify-between items-center text-xs mb-3">
        <span :class="statusClass">{{ status }}</span>
        <span class="bg-indigo-50 text-indigo-700 px-3 py-1 rounded-full font-medium">Schedule</span>
      </div>

      <div class="text-sm text-gray-500 space-y-1 mb-5">
        <div><strong>Option:</strong> {{ option }}</div>
        <div><strong>Days:</strong> {{ days }}</div>
        <div><strong>Time:</strong> {{ time }}</div>
        <div><strong>Date:</strong> {{ date }} – {{ endDate }}</div>
      </div>

      <button
        @click="goToDetail"
        class="w-full bg-indigo-600 text-white font-semibold py-2.5 rounded-lg hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-opacity-50 transition duration-300"
      >
        Book Appointment
      </button>
    </div>
  </div>
</template>

<script setup>
import { useRouter } from 'vue-router';
import { computed } from 'vue';
import { useBookmarkStore } from '@/stores/bookmark';

const props = defineProps({
  id: Number,
  title: String,
  description: String,
  status: String,
  date: String,
  endDate: String,
  option: String,
  days: String,
  time: String,
  image: String
});

const router = useRouter();
const bookmarkStore = useBookmarkStore();

const statusClass = computed(() =>
  props.status === 'Available Now'
    ? 'bg-green-100 text-green-700 px-3 py-1 rounded-full font-medium'
    : 'bg-gray-100 text-gray-700 px-3 py-1 rounded-full font-medium'
);

const isServiceBookmarked = computed(() => {
  return bookmarkStore.isBookmarked(props.id);
});

const goToDetail = () => {
  router.push({ name: 'client-detail-service', params: { id: props.id } });
};

const toggleBookmark = () => {
  if (isServiceBookmarked.value) {
    bookmarkStore.removeBookmark(props.id);
  } else {
    bookmarkStore.addBookmark(props.id);
  }
};
</script>