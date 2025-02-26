<template>
    <div>
      <Navbar />
      <HeroSection />
      <Services />
      <HowItWorks />
      <Footer />
    </div>
  </template>
  
  <script>
  import Navbar from '@/components/Client/layout/Navbar.vue'
  import HeroSection from '@/components/Client/sections/HeroSection.vue'
  import Services from '@/components/Client/sections/Services.vue';
  import HowItWorks from '@/components/Client/sections/HowItWorks.vue';
  import Footer from '@/components/Client/layout/Footer.vue';
  
  export default {
    components: {
      Navbar,
      HeroSection,
      Services,
      HowItWorks,
      Footer,
    },
  };
  </script>
  