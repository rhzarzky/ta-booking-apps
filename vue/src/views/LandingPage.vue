<template>
  <div class="relative min-h-screen bg-gray-50 font-sans text-gray-800 overflow-x-hidden">
    <nav class="bg-white shadow-md py-4 px-4 sm:px-8 sticky top-0 z-50">
      <div class="container mx-auto flex justify-between items-center">
        <router-link to="/" class="flex items-center space-x-2">
          <img src="@/assets/images/Appointly.png" alt="Appointly Logo" class="h-10" />
        </router-link>

        <ul class="hidden md:flex space-x-8 text-lg">
          <li><a href="#home" class="text-indigo-600 font-semibold hover:text-indigo-800 transition duration-200">Home</a></li>
          <li><a href="#about" class="hover:text-indigo-600 transition duration-200">About Us</a></li>
          <li><a href="#features" class="hover:text-indigo-600 transition duration-200">Features</a></li>
          <li><a href="#contact" class="hover:text-indigo-600 transition duration-200">Contact Us</a></li>
          <li><a href="#faq" class="hover:text-indigo-600 transition duration-200">FAQ</a></li>
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
            <li><a href="#features" @click="isOpen = false" class="block py-2 hover:bg-gray-50 rounded-md transition duration-200">Features</a></li>
            <li><a href="#contact" @click="isOpen = false" class="block py-2 hover:bg-gray-50 rounded-md transition duration-200">Contact Us</a></li>
            <li><a href="#faq" @click="isOpen = false" class="block py-2 hover:bg-gray-50 rounded-md transition duration-200">FAQ</a></li>
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
            Effortless <span class="text-indigo-600">Appointments</span> for Your Business
          </h1>
          <p class="text-gray-600 mt-6 text-lg max-w-lg md:max-w-none mx-auto md:mx-0">
            Streamline your scheduling, reduce no-shows, and provide a seamless booking experience for your clients.
          </p>
          <div class="mt-10 flex justify-center md:justify-start space-x-4">
            <router-link
              to="/register"
              class="bg-indigo-600 text-white px-8 py-4 rounded-full font-bold text-lg shadow-lg hover:bg-indigo-700 transition duration-300 transform hover:-translate-y-1 hover:scale-105"
            >
              Get Started
            </router-link>
            <a href="#features" class="px-8 py-4 rounded-full font-bold text-lg text-indigo-600 border border-indigo-600 hover:bg-indigo-50 transition duration-300 transform hover:-translate-y-1 hover:scale-105">
              Learn More
            </a>
          </div>
        </div>

        <div class="md:w-1/2 flex justify-center mt-12 md:mt-0 relative animate-zoom-in">
          <img src="@/assets/images/booking.jpg" alt="Appointment Booking Illustration" class="max-w-md w-full rounded-xl shadow-2xl transform rotate-3 hover:rotate-0 transition-transform duration-500 ease-in-out">
          <div class="absolute -bottom-8 -left-8 bg-blue-200 w-24 h-24 rounded-full opacity-70 animate-pulse hidden md:block"></div>
          <div class="absolute top-0 right-0 bg-yellow-200 w-16 h-16 rounded-full opacity-70 animate-bounce-slow hidden md:block"></div>
        </div>
      </div>
    </section>

    <section id="features" class="py-20 bg-white">
      <div class="container mx-auto text-center px-6">
        <h2 class="text-4xl font-extrabold text-gray-900 mb-4 animate-fade-in-up">
          Key <span class="text-indigo-600">Features</span> for Seamless Scheduling
        </h2>
        <p class="text-gray-600 mt-2 text-lg max-w-2xl mx-auto mb-12 animate-fade-in-up delay-200">
          Our platform offers robust tools designed to simplify appointment management for businesses of all sizes.
        </p>

        <div
          class="max-w-screen-lg mx-auto grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-8"
        >
          <div
            v-for="(feature, index) in features"
            :key="index"
            class="relative bg-white p-8 pt-12 shadow-lg rounded-xl text-center border-t-4 transform transition-all duration-300 hover:scale-105 hover:shadow-2xl cursor-pointer"
            :class="feature.color"
          >
            <div
              class="absolute -top-6 left-1/2 -translate-x-1/2 w-16 h-16 flex justify-center items-center rounded-full shadow-lg"
              :class="feature.iconBg"
            >
              <img :src="feature.icon" :alt="feature.title" class="w-8 h-8 filter invert" />
            </div>

            <h3 class="text-xl font-bold mt-6 text-gray-900">{{ feature.title }}</h3>
            <p class="text-gray-600 mt-3 text-base">
              {{ feature.description }}
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
            How Appointly <span class="text-indigo-600">Works</span>
          </h2>
          <p class="text-gray-600 mt-2 text-lg mb-8">
            Our intuitive platform makes booking and managing appointments incredibly easy for both you and your clients.
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
                Ready to Get Started? <br class="hidden md:block"> Book Your First Appointment Today!
            </h2>
            <router-link
                to="/register"
                class="bg-white text-indigo-600 px-8 py-4 rounded-full font-bold text-lg shadow-lg hover:bg-gray-100 transition duration-300 transform hover:-translate-y-1 hover:scale-105"
            >
                Sign Up Now
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
            <p class="text-gray-400 text-sm mb-4">Smart Scheduling Solutions for Your Business.</p>
            <div class="flex space-x-5 mt-3">
              <a href="#" class="text-blue-500 hover:text-blue-400 transition transform hover:-translate-y-1 text-2xl"><i class="fab fa-facebook-f"></i></a>
              <a href="#" class="text-pink-400 hover:text-pink-300 transition transform hover:-translate-y-1 text-2xl"><i class="fab fa-instagram"></i></a>
              <a href="#" class="text-blue-300 hover:text-blue-200 transition transform hover:-translate-y-1 text-2xl"><i class="fab fa-twitter"></i></a>
              <a href="#" class="text-red-500 hover:text-red-400 transition transform hover:-translate-y-1 text-2xl"><i class="fab fa-youtube"></i></a>
            </div>
          </div>

          <div>
            <h3 class="font-bold text-lg text-white mb-4">Company</h3>
            <ul class="space-y-3 text-gray-400">
              <li><a href="#about" class="hover:text-white transition duration-200">About Us</a></li>
              <li><a href="#contact" class="hover:text-white transition duration-200">Contact</a></li>
              <li><a href="#" class="hover:text-white transition duration-200">Careers</a></li>
              <li><a href="#" class="hover:text-white transition duration-200">Our Team</a></li>
            </ul>
          </div>

          <div>
            <h3 class="font-bold text-lg text-white mb-4">Features</h3>
            <ul class="space-y-3 text-gray-400">
              <li><a href="#features" class="hover:text-white transition duration-200">Online Booking</a></li>
              <li><a href="#features" class="hover:text-white transition duration-200">Client Management</a></li>
              <li><a href="#features" class="hover:text-white transition duration-200">Automated Reminders</a></li>
              <li><a href="#features" class="hover:text-white transition duration-200">Calendar Sync</a></li>
            </ul>
          </div>

          <div>
            <h3 class="font-bold text-lg text-white mb-4">Resources</h3>
            <ul class="space-y-3 text-gray-400">
              <li><a href="#" class="hover:text-white transition duration-200">Help Center</a></li>
              <li><a href="#faq" class="hover:text-white transition duration-200">FAQ</a></li>
              <li><a href="#" class="hover:text-white transition duration-200">Guides</a></li>
              <li><a href="#" class="hover:text-white transition duration-200">Case Studies</a></li>
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
      features: [ // Renamed from 'services' to 'features'
        {
          title: 'Online Booking',
          icon: '/icons/online-booking.svg', // Ensure this icon exists and path is correct
          description: 'Allow clients to book appointments 24/7 from any device.',
          color: 'border-b-yellow-400',
          iconBg: 'bg-yellow-400',
        },
        {
          title: 'Automated Reminders',
          icon: '/icons/bell.svg', // Ensure this icon exists and path is correct
          description: 'Reduce no-shows with automated email and SMS reminders.',
          color: 'border-b-green-500',
          iconBg: 'bg-green-500',
        },
        {
          title: 'Client Management',
          icon: '/icons/user-group.svg', // Ensure this icon exists and path is correct
          description: 'Keep track of client history, preferences, and notes in one place.',
          color: 'border-b-purple-500',
          iconBg: 'bg-purple-500',
        },
        {
          title: 'Calendar Sync',
          icon: '/icons/calendar-sync.svg', // Ensure this icon exists and path is correct
          description: 'Seamlessly sync with popular calendars like Google and Outlook.',
          color: 'border-b-red-500',
          iconBg: 'bg-red-500',
        },
      ],
      steps: [
        { title: "Sign Up Easily", description: "Create your account in minutes and set up your services." },
        { title: "Customize Your Schedule", description: "Define your availability, breaks, and booking rules." },
        { title: "Share Your Booking Link", description: "Let clients discover and book appointments with ease." },
        { title: "Manage & Grow", description: "View appointments, send reminders, and track your business growth." }
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
/* Transition for Mobile Menu */
.slide-down-enter-active, .slide-down-leave-active {
  transition: all 0.3s ease-out;
  max-height: 500px;
  opacity: 1;
}
.slide-down-enter-from, .slide-down-leave-to {
  max-height: 0;
  opacity: 0;
  transform: translateY(-20px);
}

/* Keyframes for Animations */
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

/* Application of Animations */
.animate-fade-in-up {
  animation: fadeInFromBottom 0.8s ease-out forwards;
  opacity: 0;
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

/* Animation Delays */
.delay-200 { animation-delay: 0.2s; }
.delay-400 { animation-delay: 0.4s; }
.delay-600 { animation-delay: 0.6s; }

/* Invert filter for SVG icons to make them white */
.filter-invert {
    filter: invert(100%);
}
</style>