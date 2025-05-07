<script setup>
import { RouterLink } from "vue-router";
</script>

<template>
  <main
    class="min-h-screen flex flex-col items-center justify-center px-4 py-8 sm:px-6 lg:px-40"
  >
    <div
      class="relative flex flex-col sm:flex-row justify-between items-center max-w-7xl w-full"
    >
      <div class="w-full sm:w-1/2">
        <img
          src="/src/assets/image/illustration/404.svg"
          alt=""
          loading="lazy"
          class="max-h-96 sm:max-h-none"
        />
      </div>
      <div class="flex flex-col gap-6 p-6 sm:p-8 lg:p-12">
        <div class="flex flex-col gap-3">
          <div class="flex flex-col gap-1 w-32">
            <span class="text-2xl font-bold text-cobalt-950">404 Error</span>
            <hr class="border-2 border-cobalt-950 text-cobalt-950 rounded-full w-full" />
          </div>
          <div class="flex flex-col gap-1">
            <h2
              class="font-bold text-2xl sm:text-4xl lg:text-5xl text-transparent bg-gradient-to-tr from-cobalt-950 to-cobalt-800 text-clip bg-clip-text"
            >
              Oops! This Page Doesn't Exist.
            </h2>
            <p class="text-base font-medium text-cobalt-950">
              We couldn't find the page you were looking for
            </p>
          </div>
        </div>
        <router-link
          to="/Dashboard"
          class="flex gap-2 items-center px-4 py-2 md:px-6 md:py-3 rounded-2xl bg-gradient-to-b from-cobalt-950 to-cobalt-800 shadow-md shadow-cobalt-200 w-max"
        >
          <svg
            xmlns="http://www.w3.org/2000/svg"
            width="28px"
            height="28px"
            viewBox="0 0 24 24"
            class="text-white"
          >
            <path
              fill="none"
              stroke="currentColor"
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="1.5"
              d="m6 8l-4 4m0 0l4 4m-4-4h20"
            />
          </svg>
          <span class="text-base md:text-xl font-medium text-white">Go Back</span>
        </router-link>
      </div>
    </div>
  </main>
</template>