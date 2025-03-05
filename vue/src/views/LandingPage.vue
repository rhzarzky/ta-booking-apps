<template>
  <div>
    <!-- Navbar -->
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

    <!-- Hero Section -->
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

    <!-- Services Section -->
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

    <!-- How It Works Section -->
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
        </div>
      </div>
    </section>

    <!-- Footer -->
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
  </div>
</template>

<script>
export default {
  name: 'LandingPage',
  data() {
    return {
      isOpen: false,
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
      steps: [
        { title: "Contact us", description: "Contact us to boost your brand visibility." },
        { title: "Consult", description: "Always available to answer your questions." },
        { title: "Place order", description: "Buy our package today to proceed." },
        { title: "Payment", description: "We receive payments in all types of banking." }
      ],
    };
  },
  methods: {
    toggleMenu() {
      this.isOpen = !this.isOpen;
    },
  },
};
</script>

