<!-- Pagination.vue -->
<script setup>
import { computed } from "vue";

const props = defineProps({
  currentPage: {
    type: Number,
    required: true,
  },
  totalPages: {
    type: Number,
    required: true,
  },
  hasNextPage: {
    type: Boolean,
    required: true,
  },
  hasPrevPage: {
    type: Boolean,
    required: true,
  },
});

const emit = defineEmits(["page-change"]);

const visiblePages = computed(() => {
  const maxVisiblePages = 7;
  const halfVisible = Math.floor(maxVisiblePages / 2);
  let startPage = Math.max(props.currentPage - halfVisible, 1);
  let endPage = Math.min(startPage + maxVisiblePages - 1, props.totalPages);

  if (endPage - startPage + 1 < maxVisiblePages) {
    startPage = Math.max(endPage - maxVisiblePages + 1, 1);
  }

  return Array.from(
    { length: endPage - startPage + 1 },
    (_, i) => startPage + i
  );
});

const goToPage = (page) => {
  if (page >= 1 && page <= props.totalPages) {
    emit("page-change", page);
  }
};

const goToFirstPage = () => goToPage(1);
const goToLastPage = () => goToPage(props.totalPages);
const goToPrevPage = () => goToPage(props.currentPage - 1);
const goToNextPage = () => goToPage(props.currentPage + 1);
</script>

<template>
  <div class="flex items-center justify-between px-4 py-3 sm:px-6">
    <!-- Mobile pagination -->
    <div class="flex flex-1 justify-between sm:hidden">
      <button
        @click="goToPrevPage"
        :disabled="!hasPrevPage"
        :class="[
          'relative inline-flex items-center rounded-md border px-4 py-2 text-sm font-medium',
          !hasPrevPage
            ? 'border-gray-300 bg-gray-100 text-gray-400 cursor-not-allowed'
            : 'border-gray-300 bg-white text-gray-800 hover:bg-gray-50',
        ]"
      >
        Previous
      </button>
      <button
        @click="goToNextPage"
        :disabled="!hasNextPage"
        :class="[
          'relative inline-flex items-center rounded-md border px-4 py-2 text-sm font-medium',
          !hasNextPage
            ? 'border-gray-300 bg-gray-100 text-gray-400 cursor-not-allowed'
            : 'border-gray-300 bg-white text-gray-800 hover:bg-gray-50',
        ]"
      >
        Next
      </button>
    </div>

    <!-- Desktop pagination -->
    <div class="hidden sm:flex sm:flex-1 sm:items-center sm:justify-between">
      <div>
        <p class="text-sm text-gray-700">
          Showing page
          <span class="font-medium">{{ currentPage }}</span>
          of
          <span class="font-medium">{{ totalPages }}</span>
        </p>
      </div>
      <nav class="isolate inline-flex -space-x-px rounded-md shadow-sm">
        <!-- First page -->
        <button
          @click="goToFirstPage"
          :disabled="!hasPrevPage"
          class="relative inline-flex items-center rounded-l-md px-2 py-2 text-gray-400 ring-1 ring-inset ring-gray-300 hover:bg-gray-50"
          :class="{ 'cursor-not-allowed': !hasPrevPage }"
        >
          <span class="sr-only">First</span>
          <svg class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
            <path
              fill-rule="evenodd"
              d="M12.707 5.293a1 1 0 010 1.414L9.414 10l3.293 3.293a1 1 0 01-1.414 1.414l-4-4a1 1 0 010-1.414l4-4a1 1 0 011.414 0z"
              clip-rule="evenodd"
            />
          </svg>
        </button>

        <!-- Page numbers -->
        <button
          v-for="page in visiblePages"
          :key="page"
          @click="goToPage(page)"
          :class="[
            'relative inline-flex items-center px-4 py-2 text-sm font-semibold',
            page === currentPage
              ? 'z-10 bg-cobalt-700 text-white focus:z-20 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-colbg-cobalt-700'
              : 'text-codgray-900 ring-1 ring-inset ring-wilborder-wildsand-300 hover:bg-wildsand-50 focus:z-20 focus:outline-offset-0',
          ]"
        >
          {{ page }}
        </button>

        <!-- Last page -->
        <button
          @click="goToLastPage"
          :disabled="!hasNextPage"
          class="relative inline-flex items-center rounded-r-md px-2 py-2 text-gray-400 ring-1 ring-inset ring-gray-300 hover:bg-gray-50"
          :class="{ 'cursor-not-allowed': !hasNextPage }"
        >
          <span class="sr-only">Last</span>
          <svg class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
            <path
              fill-rule="evenodd"
              d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z"
              clip-rule="evenodd"
            />
          </svg>
        </button>
      </nav>
    </div>
  </div>
</template>