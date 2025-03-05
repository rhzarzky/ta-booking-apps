<template>
    <div class="p-8">
      <h1 class="text-2xl font-bold mb-8">Dashboard</h1>
  
      <!-- Statistik Card -->
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-8">
        <div class="bg-white p-6 rounded-lg shadow">
          <h2 class="text-lg font-semibold">5</h2>
          <p class="text-gray-600">Approved Event</p>
          <p class="text-sm text-gray-500">Last: 30 days</p>
        </div>
        <div class="bg-white p-6 rounded-lg shadow">
          <h2 class="text-lg font-semibold">5</h2>
          <p class="text-gray-600">Under Review</p>
          <p class="text-sm text-gray-500">Last: 30 days</p>
        </div>
        <div class="bg-white p-6 rounded-lg shadow">
          <h2 class="text-lg font-semibold">5</h2>
          <p class="text-gray-600">Declined Event</p>
          <p class="text-sm text-gray-500">Last: 30 days</p>
        </div>
      </div>
  
      <!-- Analytics Section -->
      <div class="bg-white p-6 rounded-lg shadow mb-8">
        <h2 class="text-xl font-bold mb-4">Analytics</h2>
        <ul>
          <li class="mb-2">Activity</li>
          <li class="mb-2">Activity</li>
          <li>Profile</li>
        </ul>
      </div>
  
      <!-- Recent Activity Table -->
      <div class="bg-white p-6 rounded-lg shadow">
        <h2 class="text-xl font-bold mb-4">Recent Activity</h2>
        <table class="min-w-full">
          <thead>
            <tr>
              <th class="text-left py-2">No</th>
              <th class="text-left py-2">Activity</th>
              <th class="text-left py-2">Status</th>
              <th class="text-left py-2">Date</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(activity, index) in activities" :key="index" class="border-b">
              <td class="py-2">{{ index + 1 }}</td>
              <td class="py-2">{{ activity.name }}</td>
              <td class="py-2">{{ activity.status }}</td>
              <td class="py-2">{{ activity.date }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </template>
  
  <script>
  export default {
    name: 'Dashboard',
    data() {
      return {
        activities: [
          { name: 'Service electrical house', status: '[C:\\Users\\Desktop\\AppData\\Documents]', date: 'Aug 23, 2025 04:00 AM' },
          { name: 'Service electrical house', status: '[C:\\Users\\Desktop\\AppData\\Documents]', date: 'Aug 23, 2025 04:00 AM' },
          { name: 'Service electrical house', status: '[C:\\Users\\Desktop\\AppData\\Documents]', date: 'Aug 23, 2025 04:00 AM' },
          { name: 'Service electrical house', status: '[C:\\Users\\Desktop\\AppData\\Documents]', date: 'Aug 23, 2025 04:00 AM' },
          { name: 'Service electrical house', status: '[C:\\Users\\Desktop\\AppData\\Documents]', date: 'Aug 23, 2025 04:00 AM' },
          { name: 'Service electrical house', status: '[C:\\Users\\Desktop\\AppData\\Documents]', date: 'Aug 23, 2025 04:00 AM' },
          { name: 'Service electrical house', status: '[C:\\Users\\Desktop\\AppData\\Documents]', date: 'Aug 23, 2025 04:00 AM' },
        ],
      };
    },
  };
  </script>
  
  <style scoped>
  /* Tambahkan gaya khusus jika diperlukan */
  </style>