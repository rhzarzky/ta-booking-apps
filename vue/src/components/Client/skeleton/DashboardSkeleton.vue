<template>
  <div class="p-4 space-y-6 animate-pulse">

    <!-- Skeleton Summary Cards -->
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
      <div
        v-for="i in 4"
        :key="i"
        class="h-24 bg-gray-200 rounded-lg shadow"
      ></div>
    </div>

    <!-- Skeleton Analytics Chart -->
    <div class="h-64 bg-gray-200 rounded-lg shadow"></div>

    <!-- Recent Activity Header -->
    <div class="flex items-center justify-between mb-2">
      <div class="h-6 bg-gray-200 rounded w-40"></div>
      <div class="h-4 bg-gray-200 rounded w-24"></div>
    </div>

    <!-- Skeleton Table -->
    <div class="bg-white shadow rounded-lg p-4">
      <div class="h-6 bg-gray-200 rounded w-32 mb-4"></div>
      <div class="space-y-2">
        <div
          v-for="i in 5"
          :key="i"
          class="grid grid-cols-4 gap-4 py-2 border-t"
        >
          <div class="h-4 bg-gray-200 rounded w-full"></div>
          <div class="h-4 bg-gray-200 rounded w-full"></div>
          <div class="h-4 bg-gray-200 rounded w-full"></div>
          <div class="h-4 bg-gray-200 rounded w-full"></div>
        </div>
      </div>
    </div>

  </div>
</template>


