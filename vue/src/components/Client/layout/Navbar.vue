<template>
  <nav class="bg-white shadow-md py-4 px-8">
    <div class="container mx-auto flex justify-between items-center">
      <!-- Logo -->
      <div class="flex items-center space-x-2">
        <img src="@/assets/images/Appointly.png" alt="Appointly Logo" class="h-10" />
      </div>

      <!-- Menu Navigasi -->
      <ul class="hidden md:flex space-x-6 text-gray-700">
        <li><a href="#" class="text-primary-500 font-semibold">Home</a></li>
        <li><a href="#" class="hover:text-primary-500">About us</a></li>
        <li><a href="#" class="hover:text-primary-500">Services</a></li>
        <li><a href="#" class="hover:text-primary-500">Contact us</a></li>
        <li><a href="#" class="hover:text-primary-500">Blog</a></li>
      </ul>

      <!-- Tombol Sign In -->
      <router-link
        to="/login"
        class="bg-primary-500 text-white px-5 py-2 rounded-lg hidden md:block"
      >
        Sign in
      </router-link>

      <!-- Tombol Hamburger (Mobile) -->
      <button @click="toggleMenu" class="md:hidden text-gray-700 focus:outline-none">☰</button>
    </div>

    <!-- Menu Mobile -->
    <div v-if="isOpen" class="md:hidden bg-white py-4 px-6">
      <ul class="flex flex-col space-y-4 text-gray-700">
        <li><a href="#" class="text-primary-500 font-semibold">Home</a></li>
        <li><a href="#" class="hover:text-primary-500">About us</a></li>
        <li><a href="#" class="hover:text-primary-500">Services</a></li>
        <li><a href="#" class="hover:text-primary-500">Contact us</a></li>
        <li><a href="#" class="hover:text-primary-500">Blog</a></li>
      </ul>

      <!-- Tombol Sign In untuk Mobile -->
      <router-link
        to="/login"
        class="mt-4 primary-500 text-white px-5 py-2 rounded-lg w-full block text-center"
      >
        Sign In
      </router-link>
    </div>
  </nav>
</template>

<script>
export default {
  data() {
    return {
      isOpen: false,
    }
  },
  methods: {
    toggleMenu() {
      this.isOpen = !this.isOpen
    },
  },
}
</script>
