<template>
  <main class="min-h-screen flex flex-col items-center justify-center bg-gray-50 px-4 py-8 overflow-hidden font-sans">
    <div class="relative flex flex-col lg:flex-row items-center justify-center max-w-6xl w-full bg-white rounded-3xl shadow-2xl p-8 md:p-12 lg:p-16 gap-8 lg:gap-16">
      <div class="w-full lg:w-1/2 flex justify-center items-center order-2 lg:order-1 animate-slide-in-left">
        <img
          src="/src/assets/icons/4044.svg"
          alt="404 Illustration"
          loading="lazy"
          class="max-h-72 sm:max-h-96 lg:max-h-[450px] w-full object-contain drop-shadow-xl"
        />
      </div>

      <div class="flex flex-col gap-5 sm:gap-7 p-4 text-center lg:text-left order-1 lg:order-2 animate-slide-in-right">
        <div class="flex flex-col items-center lg:items-start gap-2">
          <span class="text-3xl sm:text-4xl font-extrabold text-red-500 tracking-wide uppercase">Error 404</span>
          <hr class="border-b-4 border-red-500 rounded-full w-20 sm:w-28 opacity-75" />
        </div>
        <div class="flex flex-col gap-3">
          <h2
            class="font-extrabold text-4xl sm:text-5xl lg:text-6xl leading-tight text-gray-900 drop-shadow-sm"
          >
            Page Not Found
          </h2>
          <p class="text-base sm:text-lg font-medium text-gray-600 max-w-lg mx-auto lg:mx-0">
            We couldn't find the page you were looking for. It might have been removed, moved, or you might have mistyped the address.
          </p>
        </div>

        <router-link
          to="/client/dashboard"
          class="inline-flex items-center justify-center gap-3 px-7 py-3 md:px-9 md:py-4 rounded-full bg-indigo-600 text-white font-semibold text-lg shadow-lg hover:shadow-xl hover:bg-indigo-700 transition duration-300 transform hover:-translate-y-1 self-center lg:self-start"
        >
          <svg
            xmlns="http://www.w3.org/2000/svg"
            class="w-6 h-6"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
            stroke-width="2.5"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              d="M10 19l-7-7m0 0l7-7m-7 7h18"
            />
          </svg>
          <span class="whitespace-nowrap">Go Back to Dashboard</span>
        </router-link>
      </div>
    </div>
  </main>
</template>

<script setup>
import { RouterLink } from "vue-router";
</script>

<style scoped>
/* Keyframes for animations */
@keyframes slideInLeft {
  from {
    opacity: 0;
    transform: translateX(-100px);
  }
  to {
    opacity: 1;
    transform: translateX(0);
  }
}

@keyframes slideInRight {
  from {
    opacity: 0;
    transform: translateX(100px);
  }
  to {
    opacity: 1;
    transform: translateX(0);
  }
}

/* Apply animations */
.animate-slide-in-left {
  animation: slideInLeft 0.8s ease-out forwards;
  opacity: 0; /* Ensures elements are hidden before animation starts */
}

.animate-slide-in-right {
  animation: slideInRight 0.8s ease-out forwards;
  opacity: 0;
  animation-delay: 0.2s; /* Add a slight delay for the right section */
}

/* General transitions for hover effects on the button */
.transform {
  transition-property: transform;
}
.transition-all {
  transition-duration: 300ms;
  transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
}
.hover\:-translate-y-1:hover {
  transform: translateY(-0.25rem);
}
</style>