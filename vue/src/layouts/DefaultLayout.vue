<template>
    <div class="default-layout flex">
      <Sidebar />
      <div class="content flex-1 p-8">
        <router-view />
      </div>
    </div>
  </template>
  
  <script>
  import Sidebar from '@/components/Client/Sidebar.vue';
  
  export default {
    name: 'DefaultLayout',
    components: {
      Sidebar,
    },
  };
  </script>
  
  <style scoped>
  .default-layout {
    min-height: 100vh;
  }
  </style>