<template>
  <div class="min-h-screen w-full bg-white rounded-xl">
    <!-- Header Section -->
    <div
      class="mx-4 bg-white items-center flex flex-col sm:flex-row gap-4 justify-between"
    >
      <div class="px-3 w-full sm:w-2/3 pt-4">
        <!-- Timestamp and permalink skeleton -->
        <div class="animate-pulse space-y-3">
          <div class="h-4 bg-skeltonBg-100 rounded w-48"></div>
          <div class="h-6 bg-skeltonBg-100 rounded w-full"></div>
          <div class="h-4 bg-skeltonBg-100 rounded w-3/4"></div>
        </div>
      </div>

      <div class="flex items-center justify-center md:justify-end gap-3 px-4 w-full">
        <!-- Action buttons skeleton -->
        <div class="animate-pulse flex gap-3 px-4">
          <div class="h-10 bg-skeltonBg-100 rounded w-24"></div>
          <div class="h-10 bg-skeltonBg-100 rounded w-24"></div>
          <div class="h-10 bg-skeltonBg-100 rounded w-32"></div>
        </div>
      </div>
    </div>

    <hr class="border border-wildsand-200 my-6" />

    <div class="mx-4 md:mx-6 flex flex-col gap-20">
      <!-- Error Stats Section -->
      <div class="flex flex-col justify-between gap-4 md:gap-6">
        <div class="animate-pulse space-y-4">
          <div class="h-6 bg-skeltonBg-100 rounded w-3/4"></div>
          <div class="h-4 bg-skeltonBg-100 rounded w-1/2"></div>

          <!-- Stats Cards -->
          <div class="grid grid-cols-2 md:grid-cols-4 gap-3 w-full">
            <div
              v-for="i in 4"
              :key="i"
              class="border border-wildsand-200 rounded-lg flex flex-col"
            >
              <div class="bg-wildsand-50 p-4 border-b border-wildsand-200">
                <div class="h-4 bg-skeltonBg-100 rounded w-full"></div>
              </div>
              <div class="p-4">
                <div class="h-6 bg-skeltonBg-100 rounded w-1/2 mx-auto"></div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Chart Section -->
      <div class="flex flex-col gap-4 md:gap-6">
        <div class="animate-pulse">
          <div class="h-6 bg-skeltonBg-100 rounded w-48 mb-4"></div>
          <div class="h-64 bg-skeltonBg-100 rounded w-full"></div>
        </div>
      </div>

      <!-- Stack Trace Section -->
      <div class="animate-pulse">
        <div class="h-6 bg-skeltonBg-100 rounded w-48 mb-6"></div>

        <!-- Stack Frames -->
        <div v-for="i in 3" :key="i" class="mb-4">
          <div class="border border-cobalt-100 rounded-xl overflow-hidden">
            <div class="bg-cobalt-50 p-4 border-b border-cobalt-100">
              <div class="h-4 bg-skeltonBg-100 rounded w-3/4"></div>
            </div>
            <div class="p-4 space-y-2">
              <div
                v-for="j in 3"
                :key="j"
                class="h-4 bg-skeltonBg-100 rounded w-full"
              ></div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.animate-pulse {
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
</style>