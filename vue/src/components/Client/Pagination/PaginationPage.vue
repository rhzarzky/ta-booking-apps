<template>
  <div class="flex justify-between items-center mt-6 text-sm text-gray-500 flex-wrap gap-4">
    <p>Showing page {{ currentPage }} of {{ totalPages }}</p>
    
    <div class="flex items-center gap-1 flex-wrap">
      <!-- First Page -->
      <button
        class="border border-indigo-600 h-10 w-10 flex items-center justify-center rounded"
        @click="changePage(1)"
        :disabled="currentPage === 1"
      >
        «
      </button>

      <!-- Prev Page -->
      <button
        class="border border-indigo-600 h-10 w-10 flex items-center justify-center rounded"
        @click="changePage(currentPage - 1)"
        :disabled="currentPage === 1"
      >
        &lt;
      </button>

      <!-- Page Numbers with Ellipsis -->
      <template v-for="page in visiblePages" :key="page">
        <button
          v-if="page === '...'"
          disabled
          class="h-10 w-10 flex items-center justify-center text-gray-400"
        >
          ...
        </button>
        <button
          v-else
          class="border border-indigo-600 h-10 w-10 flex items-center justify-center"
          :class="{
            'bg-indigo-600 text-white': page === currentPage,
            'bg-white text-indigo-600': page !== currentPage,
          }"
          @click="changePage(page)"
        >
          {{ page }}
        </button>
      </template>

      <!-- Next Page -->
      <button
        class="border border-indigo-600 h-10 w-10 flex items-center justify-center rounded"
        @click="changePage(currentPage + 1)"
        :disabled="currentPage === totalPages"
      >
        &gt;
      </button>

      <!-- Last Page -->
      <button
        class="border border-indigo-600 h-10 w-10 flex items-center justify-center rounded"
        @click="changePage(totalPages)"
        :disabled="currentPage === totalPages"
      >
        »
      </button>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  currentPage: {
    type: Number,
    required: true,
  },
  totalPages: {
    type: Number,
    required: true,
  },
  maxVisible: {
    type: Number,
    default: 5, // max number of pages visible in center
  },
})

const emit = defineEmits(['page-change'])

const changePage = (page) => {
  if (page >= 1 && page <= props.totalPages) {
    emit('page-change', page)
  }
}

// Generate visible page numbers with ellipsis
const visiblePages = computed(() => {
  const pages = []
  const { currentPage, totalPages, maxVisible } = props

  const half = Math.floor(maxVisible / 2)
  let start = Math.max(2, currentPage - half)
  let end = Math.min(totalPages - 1, currentPage + half)

  if (currentPage <= half) {
    start = 2
    end = Math.min(totalPages - 1, maxVisible)
  }

  if (currentPage + half >= totalPages) {
    end = totalPages - 1
    start = Math.max(2, totalPages - maxVisible + 1)
  }

  // Always include the first page
  pages.push(1)

  // Add ellipsis if needed
  if (start > 2) pages.push('...')

  for (let i = start; i <= end; i++) {
    pages.push(i)
  }

  if (end < totalPages - 1) pages.push('...')

  // Always include the last page
  if (totalPages > 1) pages.push(totalPages)

  return pages
})
</script>
