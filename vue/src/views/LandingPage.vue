<template>
  <div class="relative min-h-screen bg-gray-50 font-sans text-gray-800 overflow-x-hidden">
    <nav class="bg-white shadow-md py-4 px-4 sm:px-8 sticky top-0 z-50">
      <div class="container mx-auto flex justify-between items-center">
        <router-link to="/" class="flex items-center space-x-2">
          <img src="@/assets/images/Appointly.png" alt="Appointly Logo" class="h-10" />
          <span class="text-xl font-bold text-gray-800">Appointly</span>
        </router-link>

        <ul class="hidden md:flex space-x-8 text-lg">
          <li><a href="#home" class="text-indigo-600 font-semibold hover:text-indigo-800 transition duration-200">Home</a></li>
          <li><a href="#about" class="hover:text-indigo-600 transition duration-200">About Us</a></li>
          <li><a href="#services" class="hover:text-indigo-600 transition duration-200">Services</a></li>
          <li><a href="#contact" class="hover:text-indigo-600 transition duration-200">Contact Us</a></li>
          <li><a href="#blog" class="hover:text-indigo-600 transition duration-200">Blog</a></li>
        </ul>

        <router-link
          to="/login"
          class="bg-indigo-600 text-white px-6 py-2 rounded-lg shadow-md hidden md:block hover:bg-indigo-700 transition duration-300 transform hover:-translate-y-1"
        >
          Sign In
        </router-link>

        <button @click="toggleMenu" class="md:hidden text-gray-700 focus:outline-none p-2 rounded-md hover:bg-gray-100 transition duration-200">
          <svg v-if="!isOpen" xmlns="http://www.w3.org/2000/svg" class="h-8 w-8" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round" d="M4 6h16M4 12h16m-7 6h7" />
          </svg>
          <svg v-else xmlns="http://www.w3.org/2000/svg" class="h-8 w-8" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>
      </div>

      <transition name="slide-down">
        <div v-if="isOpen" class="md:hidden bg-white py-4 px-6 shadow-lg absolute w-full left-0 mt-4 border-t border-gray-100">
          <ul class="flex flex-col space-y-4 text-gray-700 text-lg">
            <li><a href="#home" @click="isOpen = false" class="block text-indigo-600 font-semibold py-2 hover:bg-gray-50 rounded-md transition duration-200">Home</a></li>
            <li><a href="#about" @click="isOpen = false" class="block py-2 hover:bg-gray-50 rounded-md transition duration-200">About Us</a></li>
            <li><a href="#services" @click="isOpen = false" class="block py-2 hover:bg-gray-50 rounded-md transition duration-200">Services</a></li>
            <li><a href="#contact" @click="isOpen = false" class="block py-2 hover:bg-gray-50 rounded-md transition duration-200">Contact Us</a></li>
            <li><a href="#blog" @click="isOpen = false" class="block py-2 hover:bg-gray-50 rounded-md transition duration-200">Blog</a></li>
          </ul>

          <router-link
            to="/login"
            class="mt-6 bg-indigo-600 text-white px-6 py-3 rounded-lg w-full block text-center font-semibold shadow-md hover:bg-indigo-700 transition duration-300"
          >
            Sign In
          </router-link>
        </div>
      </transition>
    </nav>

    <section id="home" class="py-20 md:py-32 bg-gradient-to-br from-indigo-50 to-blue-50 relative overflow-hidden">
      <div class="container mx-auto flex flex-col md:flex-row items-center justify-between px-6">
        <div class="md:w-1/2 text-center md:text-left animate-fade-in-up z-10">
          <h1 class="text-5xl lg:text-6xl font-extrabold leading-tight text-gray-900 drop-shadow-sm">
            We create <span class="text-indigo-600">solutions</span> for your business
          </h1>
          <p class="text-gray-600 mt-6 text-lg max-w-lg md:max-w-none mx-auto md:mx-0">
            Tim kami selalu mengikuti tren dan teknologi terbaru untuk memastikan kampanye pemasaran Anda tetap terdepan.
          </p>
          <div class="mt-10 flex justify-center md:justify-start space-x-4">
            <router-link
              to="/register"
              class="bg-indigo-600 text-white px-8 py-4 rounded-full font-bold text-lg shadow-lg hover:bg-indigo-700 transition duration-300 transform hover:-translate-y-1 hover:scale-105"
            >
              Get Started
            </router-link>
            </div>
        </div>

        <div class="md:w-1/2 flex justify-center mt-12 md:mt-0 relative animate-zoom-in">
          <img src="@/assets/images/booking.jpg" alt="Hero Illustration" class="max-w-md w-full rounded-xl shadow-2xl transform rotate-3 hover:rotate-0 transition-transform duration-500 ease-in-out">
          <div class="absolute -bottom-8 -left-8 bg-blue-200 w-24 h-24 rounded-full opacity-70 animate-pulse hidden md:block"></div>
          <div class="absolute top-0 right-0 bg-yellow-200 w-16 h-16 rounded-full opacity-70 animate-bounce-slow hidden md:block"></div>
        </div>
      </div>
    </section>

    <section id="services" class="py-20 bg-white">
      <div class="container mx-auto text-center px-6">
        <h2 class="text-4xl font-extrabold text-gray-900 mb-4 animate-fade-in-up">
          We Provide The Best <span class="text-indigo-600">Services</span>
        </h2>
        <p class="text-gray-600 mt-2 text-lg max-w-2xl mx-auto mb-12 animate-fade-in-up delay-200">
          Biarkan kami mengeluarkan potensi penuh bisnis Anda dengan strategi berbasis data yang teruji dan inovatif.
        </p>

        <div
          class="max-w-screen-lg mx-auto grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-8"
        >
          <div
            v-for="(service, index) in services"
            :key="index"
            class="relative bg-white p-8 pt-12 shadow-lg rounded-xl text-center border-t-4 transform transition-all duration-300 hover:scale-105 hover:shadow-2xl cursor-pointer"
            :class="service.color"
          >
            <div
              class="absolute -top-6 left-1/2 -translate-x-1/2 w-16 h-16 flex justify-center items-center rounded-full shadow-lg"
              :class="service.iconBg"
            >
              <img :src="service.icon" :alt="service.title" class="w-8 h-8 filter invert" />
            </div>

            <h3 class="text-xl font-bold mt-6 text-gray-900">{{ service.title }}</h3>
            <p class="text-gray-600 mt-3 text-base">
              Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
            </p>
          </div>
        </div>
      </div>
    </section>

    <section id="about" class="py-20 bg-indigo-50">
      <div class="container mx-auto grid grid-cols-1 md:grid-cols-2 items-center gap-12 px-6">
        <div class="flex justify-center relative animate-fade-in-left">
          <img src="@/assets/images/landing2.png" alt="How It Works" class="max-w-md w-full rounded-xl shadow-xl transform -rotate-3 hover:rotate-0 transition-transform duration-500 ease-in-out">
          <div class="absolute -top-8 -right-8 bg-green-200 w-20 h-20 rounded-full opacity-70 animate-pulse-slow hidden md:block"></div>
        </div>

        <div class="text-center md:text-left animate-fade-in-right">
          <h2 class="text-4xl font-extrabold text-gray-900 mb-4">
            Simple <span class="text-indigo-600">Solutions!</span>
          </h2>
          <p class="text-gray-600 mt-2 text-lg mb-8">
            Kami memahami bahwa setiap bisnis berbeda. Itulah mengapa kami meluangkan waktu untuk memahami kebutuhan unik Anda.
          </p>

          <div class="space-y-6">
            <div v-for="(step, index) in steps" :key="index" class="flex items-start gap-4 p-4 rounded-lg hover:bg-white transition duration-200 transform hover:scale-105 hover:shadow-md cursor-pointer">
              <div class="w-10 h-10 flex items-center justify-center rounded-full bg-indigo-600 text-white font-bold text-lg flex-shrink-0">
                {{ index + 1 }}
              </div>
              <div>
                <h3 class="text-xl font-bold text-gray-900">{{ step.title }}</h3>
                <p class="text-gray-600 text-base mt-1">{{ step.description }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <section class="bg-indigo-600 text-white py-16 px-6">
        <div class="container mx-auto flex flex-col md:flex-row items-center justify-between text-center md:text-left">
            <h2 class="text-4xl font-extrabold leading-tight mb-6 md:mb-0 max-w-2xl">
                Siap untuk memulai? <br class="hidden md:block"> Jangan ragu, kami siap membantu!
            </h2>
            <router-link
                to="/contact"
                class="bg-white text-indigo-600 px-8 py-4 rounded-full font-bold text-lg shadow-lg hover:bg-gray-100 transition duration-300 transform hover:-translate-y-1 hover:scale-105"
            >
                Hubungi Kami
            </router-link>
        </div>
    </section>

    <footer id="contact" class="bg-gray-800 text-gray-300 pt-16 pb-8">
      <div class="container mx-auto px-6">
        <div class="grid grid-cols-1 md:grid-cols-4 gap-12 py-8 border-b border-gray-700">
          <div class="flex flex-col items-center md:items-start text-center md:text-left">
            <router-link to="/" class="flex items-center space-x-3 mb-4">
              <img src="@/assets/images/Appointly.png" alt="Appointly" class="h-10" />
            </router-link>
            <p class="text-gray-400 text-sm mb-4">Solusi Penjadwalan Cerdas untuk Bisnis Anda.</p>
            <div class="flex space-x-5 mt-3">
              <a href="#" class="text-blue-500 hover:text-blue-400 transition transform hover:-translate-y-1 text-2xl"><i class="fab fa-facebook-f"></i></a>
              <a href="#" class="text-pink-400 hover:text-pink-300 transition transform hover:-translate-y-1 text-2xl"><i class="fab fa-instagram"></i></a>
              <a href="#" class="text-blue-300 hover:text-blue-200 transition transform hover:-translate-y-1 text-2xl"><i class="fab fa-twitter"></i></a>
              <a href="#" class="text-red-500 hover:text-red-400 transition transform hover:-translate-y-1 text-2xl"><i class="fab fa-youtube"></i></a>
            </div>
          </div>

          <div>
            <h3 class="font-bold text-lg text-white mb-4">Perusahaan</h3>
            <ul class="space-y-3 text-gray-400">
              <li><a href="#about" class="hover:text-white transition duration-200">Tentang Kami</a></li>
              <li><a href="#contact" class="hover:text-white transition duration-200">Kontak</a></li>
              <li><a href="#" class="hover:text-white transition duration-200">Karir</a></li>
              <li><a href="#" class="hover:text-white transition duration-200">Tim Kami</a></li>
            </ul>
          </div>

          <div>
            <h3 class="font-bold text-lg text-white mb-4">Layanan</h3>
            <ul class="space-y-3 text-gray-400">
              <li><a href="#services" class="hover:text-white transition duration-200">SEO/SEM</a></li>
              <li><a href="#services" class="hover:text-white transition duration-200">Pemasaran Digital</a></li>
              <li><a href="#services" class="hover:text-white transition duration-200">Kampanye Viral</a></li>
              <li><a href="#services" class="hover:text-white transition duration-200">Solusi Kustom</a></li>
            </ul>
          </div>

          <div>
            <h3 class="font-bold text-lg text-white mb-4">Sumber Daya</h3>
            <ul class="space-y-3 text-gray-400">
              <li><a href="#" class="hover:text-white transition duration-200">Menjadi Desainer</a></li>
              <li><a href="#blog" class="hover:text-white transition duration-200">Blog Kami</a></li>
              <li><a href="#" class="hover:text-white transition duration-200">Panduan</a></li>
              <li><a href="#" class="hover:text-white transition duration-200">Studi Kasus</a></li>
            </ul>
          </div>
        </div>
      </div>

      <div class="bg-gray-900 text-center text-gray-500 py-4 mt-8">
        <p class="text-sm">&copy; 2025 Appointly. All rights reserved.</p>
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
          title: 'SEO/SEM',
          icon: '/icons/search-engine.svg', // Pastikan ikon ini ada dan benar path-nya
          color: 'border-b-yellow-400', // Gunakan border-b untuk bawah
          iconBg: 'bg-yellow-400',
        },
        {
          title: 'Digital Marketing',
          icon: '/icons/marketing-growth.svg', // Pastikan ikon ini ada dan benar path-nya
          color: 'border-b-green-500',
          iconBg: 'bg-green-500',
        },
        {
          title: 'Viral Campaign',
          icon: '/icons/viral-share.svg', // Pastikan ikon ini ada dan benar path-nya
          color: 'border-b-purple-500',
          iconBg: 'bg-purple-500',
        },
        {
          title: 'Custom Solutions', // Ubah Others jadi lebih spesifik
          icon: '/icons/solution.svg', // Pastikan ikon ini ada dan benar path-nya
          color: 'border-b-red-500',
          iconBg: 'bg-red-500',
        },
      ],
      steps: [
        { title: "Hubungi Kami", description: "Jangkau tim kami untuk mendiskusikan kebutuhan Anda." },
        { title: "Konsultasi Gratis", description: "Dapatkan sesi konsultasi personal untuk menemukan solusi terbaik." },
        { title: "Mulai Proyek", description: "Setelah perencanaan, kami segera memulai proyek Anda." },
        { title: "Lihat Hasil", description: "Saksikan bagaimana solusi kami membawa pertumbuhan nyata bagi bisnis Anda." }
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

<style scoped>
/* Transisi Slide Down untuk Mobile Menu */
.slide-down-enter-active, .slide-down-leave-active {
  transition: all 0.3s ease-out;
  max-height: 500px; /* Nilai yang cukup besar untuk transisi */
  opacity: 1;
}
.slide-down-enter-from, .slide-down-leave-to {
  max-height: 0;
  opacity: 0;
  transform: translateY(-20px);
}

/* Keyframes untuk Animasi */
@keyframes fadeInFromBottom {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes zoomIn {
  from {
    opacity: 0;
    transform: scale(0.9);
  }
  to {
    opacity: 1;
    transform: scale(1);
  }
}

@keyframes fadeInFromLeft {
  from {
    opacity: 0;
    transform: translateX(-50px);
  }
  to {
    opacity: 1;
    transform: translateX(0);
  }
}

@keyframes fadeInFromRight {
  from {
    opacity: 0;
    transform: translateX(50px);
  }
  to {
    opacity: 1;
    transform: translateX(0);
  }
}

@keyframes pulse {
  0%, 100% {
    transform: scale(1);
    opacity: 0.7;
  }
  50% {
    transform: scale(1.1);
    opacity: 0.9;
  }
}

@keyframes bounceSlow {
  0%, 100% {
    transform: translateY(0);
  }
  25% {
    transform: translateY(-5px);
  }
  50% {
    transform: translateY(0);
  }
  75% {
    transform: translateY(-5px);
  }
}

/* Aplikasi Animasi */
.animate-fade-in-up {
  animation: fadeInFromBottom 0.8s ease-out forwards;
  opacity: 0; /* Pastikan elemen tersembunyi sebelum animasi */
}

.animate-zoom-in {
  animation: zoomIn 0.8s ease-out forwards;
  opacity: 0;
}

.animate-fade-in-left {
  animation: fadeInFromLeft 0.8s ease-out forwards;
  opacity: 0;
}

.animate-fade-in-right {
  animation: fadeInFromRight 0.8s ease-out forwards;
  opacity: 0;
}

.animate-pulse {
  animation: pulse 2s infinite cubic-bezier(0.4, 0, 0.6, 1);
}

.animate-bounce-slow {
  animation: bounceSlow 4s infinite ease-in-out;
}

/* Delay Animasi */
.delay-200 { animation-delay: 0.2s; }
.delay-400 { animation-delay: 0.4s; }
.delay-600 { animation-delay: 0.6s; }

/* Invert filter untuk ikon SVG agar warnanya jadi putih */
.filter-invert {
    filter: invert(100%);
}
</style>