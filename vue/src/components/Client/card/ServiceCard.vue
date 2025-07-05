<template>
  <div
    class="bg-white rounded-xl shadow-md overflow-hidden transform hover:scale-102 transition duration-300 ease-in-out"
  >
    <div class="relative">
      <img :src="image" alt="Service" class="h-48 w-full object-cover" />
      <button
        @click.stop="toggleBookmark"
        :class="[
          'absolute top-3 right-3 p-2 rounded-full bg-white transition duration-300',
          isServiceBookmarked ? 'text-indigo-500' : 'text-gray-400 hover:text-indigo-400',
        ]"
        aria-label="Bookmark service"
      >
        <svg v-if="isServiceBookmarked" class="w-6 h-6 fill-current" viewBox="0 0 24 24">
          <path d="M17 3H7c-1.1 0-2 .9-2 2v16l7-3 7 3V5c0-1.1-.9-2-2-2z"/>
        </svg>
        <svg v-else class="w-6 h-6 fill-current" viewBox="0 0 24 24">
          <path d="M17 3H7c-1.1 0-2 .9-2 2v16l7-3 7 3V5c0-1.1-.9-2-2-2zm0 15l-5-2.18L7 18V5h10v13z"/>
        </svg>
      </button>
    </div>

    <div class="p-5">
      <h2 class="text-xl font-bold text-gray-900 mb-2 truncate">{{ title }}</h2>
      <p class="text-sm text-gray-600 mb-3 line-clamp-2">{{ description }}</p>

      <div class="flex items-center text-sm mb-3">
        <template v-if="normalizedAverageRating > 0">
          <div class="flex items-center mr-2">
            <svg
              v-for="n in Math.floor(normalizedAverageRating)"
              :key="'filled-' + n"
              class="w-5 h-5 text-yellow-400 fill-current"
              viewBox="0 0 20 20"
            >
              <path
                d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.538 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.783.57-1.838-.197-1.538-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.92 8.72c-.783-.57-.381-1.81.588-1.81h3.462a1 1 0 00.95-.69l1.07-3.292z"
              />
            </svg>
            <svg
              v-if="normalizedAverageRating % 1 !== 0"
              class="w-5 h-5 text-yellow-400 fill-current"
              viewBox="0 0 20 20"
            >
              <path
                d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.538 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.783.57-1.838-.197-1.538-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.92 8.72c-.783-.57-.381-1.81.588-1.81h3.462a1 1 0 00.95-.69l1.07-3.292z"
                mask="url(#half-mask)"
              />
              <mask id="half-mask">
                <rect x="0" y="0" width="10" height="20" fill="white" />
              </mask>
            </svg>
            <svg
              v-for="n in (5 - Math.ceil(normalizedAverageRating))"
              :key="'empty-' + n"
              class="w-5 h-5 text-gray-300 fill-current"
              viewBox="0 0 20 20"
            >
              <path
                d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.538 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.783.57-1.838-.197-1.538-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.92 8.72c-.783-.57-.381-1.81.588-1.81h3.462a1 1 0 00.95-.69l1.07-3.292z"
              />
            </svg>
          </div>
          <span class="text-yellow-800 font-semibold mr-1">
            {{ normalizedAverageRating.toFixed(1) }}/5
          </span>
          <span v-if="reviewCount > 0" class="text-gray-600 text-xs"> ({{ reviewCount }} review)</span>
        </template>
        <span v-else class="text-gray-500 bg-gray-100 px-3 py-1 rounded-full font-medium">
          No review yet
        </span>
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
import { useRouter } from 'vue-router'
import { computed } from 'vue'
import { useBookmarkStore } from '@/stores/bookmark' 

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
  image: String,
  averageRating: [Number, String],
  reviewCount: { 
    type: Number,
    default: 0,
  }
})

const router = useRouter()
const bookmarkStore = useBookmarkStore()

const statusClass = computed(() =>
  props.status === 'Available Now'
    ? 'bg-green-100 text-green-700 px-3 py-1 rounded-full font-medium'
    : 'bg-gray-100 text-gray-700 px-3 py-1 rounded-full font-medium',
)

const isServiceBookmarked = computed(() => {
  return bookmarkStore.isBookmarked(props.id)
})

const goToDetail = () => {
  router.push({ name: 'client-detail-service', params: { id: props.id } })
}

const toggleBookmark = () => {
  if (isServiceBookmarked.value) {
    bookmarkStore.removeBookmark(props.id)
  } else {
    bookmarkStore.addBookmark(props.id)
  }
}

// Computed property untuk memastikan averageRating adalah angka dan di antara 0-5
const normalizedAverageRating = computed(() => {
  const rating = parseFloat(props.averageRating);
  if (isNaN(rating) || rating < 0) return 0;
  if (rating > 5) return 5;
  return rating;
});
</script>