<template>
    <div class="sidebar bg-white text-gray-800 w-64 min-h-screen p-4 shadow-lg">
      <div class="flex items-center justify-center mb-8">
        <img src="@/assets/images/Appointly.png" alt="Appointly Logo" class="w-10 h-10">
      </div>
      <ul>
        <li class="mb-4">
          <router-link to="/client/dashboard" class="flex items-center p-2 hover:bg-gray-100 rounded">
            <span class="mr-2">📊</span> Dashboard
          </router-link>
        </li>
        <li class="mb-4">
          <router-link to="/client/meeting" class="flex items-center p-2 hover:bg-gray-100 rounded">
            <span class="mr-2">📅</span> Meetings
          </router-link>
        </li>
        <li class="mb-4">
          <router-link to="/client/activity" class="flex items-center p-2 hover:bg-gray-100 rounded">
            <span class="mr-2">🏃‍♂️</span> Activity
          </router-link>
        </li>
        <li class="mb-4">
          <router-link to="/client/profile" class="flex items-center p-2 hover:bg-gray-100 rounded">
            <span class="mr-2">👤</span> Profile
          </router-link>
        </li>
      </ul>
    </div>
  </template>
  
  <script>
  export default {
    name: 'Sidebar',
  };
  </script>
  
  <style scoped>
  .sidebar {
    width: 16rem; /* 64 */
  }
  </style>