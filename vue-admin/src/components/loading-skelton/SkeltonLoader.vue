<script setup>
import { defineProps } from "vue";

const props = defineProps({
  type: {
    type: String,
    default: "default",
    validator: (value) => ["table", "default", "card"].includes(value),
  },
  size: {
    type: String,
    default: "medium",
    validator: (value) => ["small", "medium", "large"].includes(value), 
  },
  rows: {
    type: Number,
    default: 5,
  },
  columns: {
    type: Number,
    default: 5,
  },
  cards: {
    type: Number,
    default: 4,
  },
});
</script>

<template>
  <div
    class="skeleton-loader w-full animate-pulse ease-in-out duration-300"
    :class="[size, type]"
  >
    <template v-if="type === 'table'">
      <div class="skeleton-table w-full mx-auto">
        <div class="skeleton-table-header flex mb-3 bg-skeltonBg-50">
          <div
            v-for="i in columns"
            :key="'header-' + i"
            class="skeleton-table-cell flex-1 h-12 bg-skeltonBg-100 m-2"
          ></div>
        </div>

        <div
          v-for="i in rows"
          :key="'row-' + i"
          class="skeleton-table-row flex mb-3"
        >
          <div
            v-for="col in columns"
            :key="'cell-' + col"
            class="skeleton-table-cell flex-1 h-8 bg-skeltonBg-100 m-2"
          ></div>
        </div>
      </div>
    </template>

    <!-- skelton cards -->
    <template v-else-if="type === 'card'">
      <div
        class="card grid grid-cols-2 sm:grid-cols-2 lg:grid-cols-4 gap-2 md:gap-4"
      >
        <div
          v-for="cardType in cards"
          :key="cardType"
          class="skeleton-dashboard-card p-4 md:p-6 rounded-xl relative flex flex-col"
          :class="{
            'bg-gradient-to-r from-red-900 to-red-600': cardType === 1,
            'bg-gradient-to-r from-yellow-900 to-yellow-600': cardType === 2,
            'bg-gradient-to-r from-green-900 to-green-600': cardType === 3,
            'bg-gradient-to-r from-codgray-900 to-codgray-600': cardType === 4,
          }"
        >
          <div
            class="skeleton-card-title h-4 md:h-6 w-1/2 mb-2 bg-white/30 rounded"
          ></div>
          <div
            class="skeleton-card-value h-8 md:h-12 w-3/4 bg-white/30 rounded"
          ></div>
          <div
            class="absolute -bottom-4 -right-4 md:-bottom-12 md:-right-9 opacity-40"
          >
            <div
              class="skeleton-card-icon w-24 md:w-40 h-24 md:h-40 bg-white/20 rounded-full"
            ></div>
          </div>
        </div>
      </div>
    </template>
    <template v-else>
      <div class="skeleton-default w-full">
        <div
          v-for="i in 1"
          :key="'default-' + i"
          class="skeleton-line h-7 bg-skeltonBg-100"
        ></div>
      </div>
    </template>
  </div>
</template>

<style scoped>
/* Base pulse animation */
.skeleton-loader {
  animation: pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite;
}

@keyframes pulse {
  0%,
  100% {
    opacity: 1;
  }
  50% {
    opacity: 0.5;
  }
}

/* Size variants */
.small {
  transform: scale(0.8);
}
.medium {
  transform: scale(1);
}
.large {
  transform: scale(1.2);
}

/* Skeleton table layout */
.skeleton-table {
  width: 100%;
  padding: 0 16px 0 16px;
}

.skeleton-table-header {
  display: flex;
  background-color: #f0f0f0;
}

.skeleton-table-cell {
  flex: 1;
  height: 56px;
  background-color: #e0e0e0;
  border-radius: 8px;
}

.skeleton-table-row {
  display: flex;
}

.skeleton-default {
  width: 100%;
}

.skeleton-line {
  height: 20px;
  background-color: #e0e0e0;
}

/* skelton cards */
/* Dashboard card skeleton styles */
.skeleton-dashboard-card {
  color: white;
}

.skeleton-card-title,
.skeleton-card-value,
.skeleton-card-icon {
  background-clip: content-box;
  animation: pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite;
}
</style>
