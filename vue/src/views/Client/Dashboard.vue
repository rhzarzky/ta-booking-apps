<script setup>
import { onMounted } from 'vue'
import { storeToRefs } from 'pinia'
import { useDashboardStore } from '@/stores/dashboard'
import SummaryCards from '@/components/Client/card/SummaryCards.vue'
import AnalyticsChart from '@/components/Client/AnalyticsChart.vue'
// import DashboardSkeleton from '@/components/Client/skeleton/DashboardSkeleton.vue';

const dashboardStore = useDashboardStore()
const { summary, latestBookings, loading, error } = storeToRefs(dashboardStore)

onMounted(() => {
  dashboardStore.fetchDashboardData()
})

// function formatDate(dateStr) {
//   const options = { year: 'numeric', month: 'long', day: 'numeric' };
//   return new Date(dateStr).toLocaleDateString('id-ID', options);
// }

function statusClass(status) {
  const base = 'px-2 py-1 rounded text-xs font-medium'
  switch ((status || '').toLowerCase()) {
    case 'pending':
      return `${base} bg-lime-100 text-lime-700`
    case 'approved':
      return `${base} bg-purple-100 text-purple-700`
    case 'declined':
      return `${base} bg-red-100 text-red-700`
    case 'completed':
      return 'bg-blue-100 text-blue-700'
    default:
      return `${base} bg-gray-100 text-gray-700`
  }
}
</script>

<template>
  <div class="p-4 space-y-6">
    <!-- Summary Cards -->
    <SummaryCards :stats="summary" />

    <!-- Analytics Chart -->
    <AnalyticsChart />

    <!-- Header recent activity -->
    <div class="flex items-center justify-between mb-2">
      <h2 class="text-lg font-semibold">Recent Activity</h2>
      <router-link to="/client/activity" class="text-blue-600 hover:underline text-sm">
        View all activities
      </router-link>
    </div>

    <!-- main Konten recent activity -->
    <div class="bg-white shadow rounded-lg p-4">
      <div v-if="loading" class="text-gray-500">Loading data...</div>
      <div v-else-if="error" class="text-red-500">{{ error }}</div>
      <div v-else>
        <table class="min-w-full table-auto text-sm">
          <thead class="bg-gray-100">
            <tr>
              <th class="px-4 py-2 text-left">No</th>
              <th class="px-4 py-2 text-left">Service</th>
              <th class="px-4 py-2 text-left">Date</th>
              <th class="px-4 py-2 text-left">Status</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="booking in latestBookings" :key="booking.id" class="border-t">
              <td class="px-4 py-2">{{ booking.displayNo }}</td>
              <td class="px-4 py-2">{{ booking.service?.title || '-' }}</td>
              <td class="px-4 py-2">{{ booking.displayDateTime }}</td>
              <td class="px-4 py-2">
                <span :class="statusClass(booking.status)">
                  {{ booking.status }}
                </span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>
