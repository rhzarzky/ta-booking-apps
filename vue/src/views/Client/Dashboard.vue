<script setup>
import { onMounted } from 'vue'
import { storeToRefs } from 'pinia'
import { useDashboardStore } from '@/stores/dashboard'
import SummaryCards from '@/components/Client/card/SummaryCards.vue'
import AnalyticsChart from '@/components/Client/AnalyticsChart.vue'

// Ambil data dari store dashboard
const dashboardStore = useDashboardStore()
const { summary, latestBookings, loading, error } = storeToRefs(dashboardStore)

// Fetch data saat komponen dimount
onMounted(() => {
  dashboardStore.fetchDashboardData()
})

// Fungsi untuk memberi warna status
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
      return `${base} bg-blue-100 text-blue-700`
    default:
      return `${base} bg-gray-100 text-gray-700`
  }
}
</script>

<template>
  <div class="p-4 space-y-6">
    <SummaryCards :stats="summary" />

    <AnalyticsChart />

    <div class="flex items-center justify-between mb-2">
      <h2 class="text-lg font-semibold text-gray-800">Recent Activity</h2>
      <router-link to="/client/activity" class="text-blue-600 hover:underline text-sm font-medium">
        View all activities
      </router-link>
    </div>

    <div class="bg-white shadow rounded-lg p-4">
      <div v-if="loading" class="text-gray-500 text-center py-4">Loading data...</div>
      <div v-else-if="error" class="text-red-500 text-center py-4">{{ error }}</div>
      <div v-else>
        <div class="overflow-x-auto">
          <table class="min-w-full table-auto text-sm divide-y divide-gray-200">
            <thead class="bg-gray-50">
              <tr>
                <th class="px-4 py-3 text-left text-gray-600 uppercase tracking-wider font-semibold">No</th>
                <th class="px-4 py-3 text-left text-gray-600 uppercase tracking-wider font-semibold">Service</th>
                <th class="px-4 py-3 text-left text-gray-600 uppercase tracking-wider font-semibold">Date</th>
                <th class="px-4 py-3 text-left text-gray-600 uppercase tracking-wider font-semibold">Status</th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
              <tr v-if="latestBookings.length === 0">
                <td colspan="4" class="px-4 py-6 text-center text-gray-500 italic">
                  No recent activity.
                </td>
              </tr>
              <tr v-for="booking in latestBookings" :key="booking.id" class="hover:bg-gray-50 transition-colors duration-150">
                <td class="px-4 py-3 whitespace-nowrap">{{ booking.displayNo }}</td>
                <td class="px-4 py-3 whitespace-nowrap">{{ booking.service?.title || '-' }}</td>
                <td class="px-4 py-3 whitespace-nowrap">{{ booking.displayDateTime }}</td>
                <td class="px-4 py-3 whitespace-nowrap">
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
  </div>
</template>

