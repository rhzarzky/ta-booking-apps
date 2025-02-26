<template>
    <section class="pt-24 pb-12 bg-white">
      <div class="container mx-auto flex flex-col md:flex-row items-center">
        <!-- Bagian Kiri: Teks -->
        <div class="md:w-1/2 text-center md:text-left px-6">
          <h1 class="text-4xl font-bold leading-tight">
            We create <span class="text-primary-500">solutions</span> for your business
          </h1>
          <p class="text-gray-600 mt-4">
            Our team keeps a keen eye on emerging trends and technologies to ensure your marketing campaigns remain cutting-edge.
          </p>
          <div class="mt-6 flex justify-center md:justify-start space-x-4">
            <router-link
              to="/register"
              class="bg-[#694CF1] text-white px-6 py-3 rounded-lg"
            >
              Get Started
            </router-link>
          </div>
        </div>
  
        <!-- Bagian Kanan: Gambar -->
        <div class="md:w-1/2 flex justify-center mt-8 md:mt-0">
          <img src="@/assets/images/booking.jpg" alt="Hero Illustration" class="max-w-md">
        </div>
      </div>
    </section>
  </template>
  