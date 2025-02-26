<template>
    <section class="py-16 bg-primary-10">
      <div class="container mx-auto grid grid-cols-1 md:grid-cols-2 items-center gap-10">
        <!-- Bagian Gambar -->
        <div class="flex justify-center">
          <img src="@/assets/images/landing2.png" alt="How It Works" class="max-w-sm">
        </div>
  
        <!-- Bagian Teks -->
        <div>
          <h2 class="text-3xl font-bold">
            Simple <span class="text-primary-500">Solutions!</span>
          </h2>
          <p class="text-gray-600 mt-2">
            We understand that no two businesses are alike. That’s why we take the time to understand.
          </p>
  
          <!-- Daftar Langkah -->
          <div class="mt-6 space-y-4">
            <div v-for="(step, index) in steps" :key="index" class="flex items-start gap-4">
              <div class="w-8 h-8 flex items-center justify-center rounded-full bg-primary-700 text-white font-bold">
                {{ index + 1 }}
              </div>
              <div>
                <h3 class="text-lg font-semibold">{{ step.title }}</h3>
                <p class="text-gray-600 text-sm">{{ step.description }}</p>
              </div>
            </div>
          </div>
  
          <!-- Tombol -->
          <!-- <div class="mt-6 flex gap-4">
            <button class="bg-orange-500 text-white py-2 px-4 rounded-lg shadow-md hover:bg-orange-600 transition">
              Get Started
            </button>
            <button class="border border-orange-500 text-orange-500 py-2 px-4 rounded-lg shadow-md hover:bg-orange-100 transition">
              Read More
            </button>
          </div> -->
        </div>
      </div>
    </section>
  </template>
  
  <script>
  export default {
    data() {
      return {
        steps: [
          { title: "Contact us", description: "Contact us to boost your brand visibility." },
          { title: "Consult", description: "Always available to answer your questions." },
          { title: "Place order", description: "Buy our package today to proceed." },
          { title: "Payment", description: "We receive payments in all types of banking." }
        ]
      };
    }
  };
  </script>
  