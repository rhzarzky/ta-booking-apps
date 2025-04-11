<template>
  <div class="p-8">
    <h1 class="text-2xl font-bold mb-8">Dashboard</h1>

    <!-- Summary Cards -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-8">
      <div class="rounded-xl p-6 text-white" style="background: linear-gradient(135deg, #7f00ff, #3c8ce7)">
        <h2 class="text-3xl font-semibold">5</h2>
        <p class="text-lg font-semibold mt-1">Approved Event</p>
        <p class="text-sm mt-2">
          Last 30 days
          <span class="text-green-500 font-semibold ml-1">+5 ▲</span>
        </p>
      </div>

      <div class="rounded-xl p-6 text-white" style="background: linear-gradient(135deg, #a8c66c, #4b5320)">
        <h2 class="text-3xl font-semibold">5</h2>
        <p class="text-lg font-semibold mt-1">Under Review</p>
        <p class="text-sm mt-2">
          Last 30 days
          <span class="text-green-500 font-semibold ml-1">+5 ▲</span>
        </p>
      </div>

      <div class="rounded-xl p-6 text-white" style="background: linear-gradient(135deg, #808080, #505050)">
        <h2 class="text-3xl font-semibold">5</h2>
        <p class="text-lg font-semibold mt-1">Declined Event</p>
        <p class="text-sm mt-2">
          Last 30 days
          <span class="text-red-500 font-semibold ml-1">-5 ▼</span>
        </p>
      </div>
    </div>

    <!-- Analytics Chart -->
    <AnalyticsChart />

    <!-- Recent Activity Table -->
    <div class="bg-white p-6 rounded-lg shadow">
      <div class="flex justify-between items-center mb-4">
        <h2 class="text-xl font-bold">Recent Activity</h2>
        <a href="#" class="text-sm text-indigo-600 hover:underline">view all activities</a>
      </div>
      <table class="min-w-full">
        <thead class="bg-indigo-50">
          <tr>
            <th class="text-left py-2 px-2">No</th>
            <th class="text-left py-2 px-2">Activity</th>
            <th class="text-left py-2 px-2">Status</th>
            <th class="text-left py-2 px-2">Date</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(activity, index) in activities" :key="index" class="border-b">
            <td class="py-2 px-2">{{ index + 1 }}</td>
            <td class="py-2 px-2">{{ activity.name }}</td>
            <td class="py-2 px-2">
              <span
                :class="[
                  'text-xs font-semibold px-2 py-1 rounded',
                  activity.status === 'Approved'
                    ? 'bg-purple-500 text-white'
                    : activity.status === 'Under Review'
                    ? 'bg-lime-300 text-black'
                    : 'bg-gray-400 text-white',
                ]"
              >
                {{ activity.status }}
              </span>
            </td>
            <td class="py-2 px-2">{{ activity.date }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>
import AnalyticsChart from '@/components/Client/AnalyticsChart.vue'

export default {
  name: 'Dashboard',
  components: {
    AnalyticsChart,
  },
  data() {
    return {
      activities: [
        { name: 'Service electrical house', status: 'Approved', date: 'Aug 23, 2025 04:00 AM' },
        { name: 'Service electrical house', status: 'Under Review', date: 'Aug 23, 2025 04:00 AM' },
        { name: 'Service electrical house', status: 'Declined', date: 'Aug 23, 2025 04:00 AM' },
        { name: 'Service electrical house', status: 'Approved', date: 'Aug 23, 2025 04:00 AM' },
        { name: 'Service electrical house', status: 'Declined', date: 'Aug 23, 2025 04:00 AM' },
        { name: 'Service electrical house', status: 'Under Review', date: 'Aug 23, 2025 04:00 AM' },
        { name: 'Service electrical house', status: 'Approved', date: 'Aug 23, 2025 04:00 AM' },
      ],
    }
  },
}
</script>
