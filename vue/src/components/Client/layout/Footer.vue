<template>
  <footer class="bg-primary-10 pt-12">
    <div class="container mx-auto px-6">
      <!-- Bagian Atas -->
      <div class="flex flex-col md:flex-row justify-between items-center border-b border-gray-300 pb-6">
        <h2 class="text-xl font-semibold text-primary-600">Ready to get started?</h2>
        <button class="mt-4 md:mt-0 border border-primary-500 text-primary-500 py-2 px-4 rounded-lg hover:bg-primary-100 transition">
          Contact Us
        </button>
      </div>

      <!-- Bagian Tengah -->
      <div class="grid grid-cols-1 md:grid-cols-4 gap-8 py-8 text-gray-700">
        <!-- Brand -->
        <div class="flex flex-col items-center md:items-start">
          <div class="flex items-center space-x-2">
            <img src="@/assets/images/Appointly.png" alt="Appointly" class="w-6 h-6">
          </div>
          <div class="flex space-x-4 mt-3">
            <a href="#" class="text-blue-600 text-xl"><i class="fab fa-facebook"></i></a>
            <a href="#" class="text-pink-500 text-xl"><i class="fab fa-instagram"></i></a>
            <a href="#" class="text-blue-400 text-xl"><i class="fab fa-twitter"></i></a>
          </div>
        </div>

        <!-- Links -->
        <div>
          <h3 class="font-semibold">Company</h3>
          <ul class="mt-2 space-y-1 text-sm">
            <li><a href="#" class="hover:text-primary-500">About</a></li>
            <li><a href="#" class="hover:text-primary-500">Contact</a></li>
            <li><a href="#" class="hover:text-primary-500">Careers</a></li>
            <li><a href="#" class="hover:text-primary-500">Team</a></li>
          </ul>
        </div>

        <div>
          <h3 class="font-semibold">Designs</h3>
          <ul class="mt-2 space-y-1 text-sm">
            <li><a href="#" class="hover:text-primary-500">Design contests</a></li>
            <li><a href="#" class="hover:text-primary-500">1-to-1 Projects</a></li>
            <li><a href="#" class="hover:text-primary-500">Find a designer</a></li>
            <li><a href="#" class="hover:text-primary-500">Discover inspiration</a></li>
            <li><a href="#" class="hover:text-primary-500">Pricing</a></li>
          </ul>
        </div>

        <div>
          <h3 class="font-semibold">Resources</h3>
          <ul class="mt-2 space-y-1 text-sm">
            <li><a href="#" class="hover:text-primary-500">Become a designer</a></li>
            <li><a href="#" class="hover:text-primary-500">Blog</a></li>
            <li><a href="#" class="hover:text-primary-500">Design without borders</a></li>
            <li><a href="#" class="hover:text-primary-500">99awards</a></li>
            <li><a href="#" class="hover:text-primary-500">Affiliates</a></li>
          </ul>
        </div>
      </div>
    </div>

    <!-- Bagian Bawah -->
    <div class="bg-primary-500 text-center text-white py-4">
      <p class="text-sm">All rights gmedia 2025</p>
    </div>
  </footer>
</template>
