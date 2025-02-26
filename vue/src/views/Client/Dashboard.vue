<template>
    <div class="flex">
      <!-- Sidebar -->
      <Sidebar />
  
      <!-- Main Content -->
      <div class="ml-64 p-8 w-full">
        <h1 class="text-2xl font-bold mb-4">Dashboard</h1>
  
        <!-- Card Statistics -->
        <div class="grid grid-cols-3 gap-4">
          <CardStats title="Approved Event" count="5" color="bg-purple-500" />
          <CardStats title="Under Review" count="5" color="bg-green-500" />
          <CardStats title="Declined Event" count="5" color="bg-gray-500" />
        </div>
  
        <!-- Analytics Chart -->
        <div class="mt-6 bg-white p-6 shadow-md rounded-lg">
          <h2 class="text-lg font-bold mb-2">Analytics</h2>
          <ChartAnalytics />
        </div>
  
        <!-- Recent Activity Table -->
        <div class="mt-6 bg-white p-6 shadow-md rounded-lg">
          <h2 class="text-lg font-bold mb-2">Recent Activity</h2>
          <RecentActivityTable />
        </div>
      </div>
    </div>
  </template>
  
  <script>
  import Sidebar from "@/components/Sidebar.vue";
  import CardStats from "@/components/CardStats.vue";
  import ChartAnalytics from "@/components/ChartAnalytics.vue";
  import RecentActivityTable from "@/components/RecentActivityTable.vue";
  
  export default {
    components: {
      Sidebar,
      CardStats,
      ChartAnalytics,
      RecentActivityTable,
    },
  };
  </script>
  