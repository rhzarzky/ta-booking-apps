<template>
    <section class="py-12 bg-white">
      <div class="container mx-auto text-center">
        <!-- Judul -->
        <h2 class="text-3xl font-bold">
          We Provide The Best <span class="text-primary-500">Services</span>
        </h2>
        <p class="text-gray-600 mt-2">
          Let us unleash the full potential of your business with our data-driven strategies.
        </p>
  
        <!-- Grid Services -->
        <div
          class="max-w-screen-lg mx-auto px-3 grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 mt-10"
        >
          <div
            v-for="(service, index) in services"
            :key="index"
            class="relative bg-white p-6 shadow-lg rounded-lg text-center border-t-4"
            :class="service.color"
          >
            <!-- Ikon dengan Background Kotak di Pojok Kiri Atas -->
            <div
              class="absolute top-0 left-0 w-12 h-12 flex justify-center items-center rounded-br-3xl"
              :class="service.iconBg"
            >
              <img :src="service.icon" :alt="service.title" class="w-6 h-6" />
            </div>
  
            <h3 class="text-lg font-semibold mt-6">{{ service.title }}</h3>
            <p class="text-gray-600 mt-2 text-sm">
              Lorem ipsum has been the industry's standard dummy text ever since the 1500s.
            </p>
          </div>
        </div>
      </div>
    </section>
  </template>
  
  <script>
  export default {
    data() {
      return {
        services: [
          {
            title: 'Seo/Sem',
            icon: '../assets/icons/phone.svg',
            color: 'border-yellow-400',
            iconBg: 'bg-yellow-400 text-white',
          },
          {
            title: 'Marketing',
            icon: '/icons/marketing-icon.png',
            color: 'border-green-500',
            iconBg: 'bg-green-500 text-white',
          },
          {
            title: 'Viral Campaign',
            icon: '/icons/viral-icon.png',
            color: 'border-purple-500',
            iconBg: 'bg-purple-500 text-white',
          },
          {
            title: 'Others',
            icon: '/icons/others-icon.png',
            color: 'border-red-500',
            iconBg: 'bg-red-500 text-white',
          },
        ],
      }
    },
  }
  </script>
  