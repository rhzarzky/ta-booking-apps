<template>
  <div class="bg-[#f9fafb] p-6 rounded-2xl shadow-sm mb-8">
    <div class="flex justify-between items-center mb-6">
      <h2 class="text-xl font-bold text-black">Analytics</h2>
      <div class="relative">
        <select
          v-model="selectedOption"
          class="appearance-none border border-gray-300 rounded-md px-5 py-2 text-sm text-gray-700 bg-white shadow-sm focus:outline-none focus:ring-2 focus:ring-purple-500"
        >
          <option value="day">Day</option>
          <option value="week">Week</option>
          <option value="month" selected>Month</option>
          <option value="year">Year</option>
        </select>
        <div class="pointer-events-none absolute inset-y-0 right-3 flex items-center text-gray-500">
          <svg class="w-4 h-4" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7" />
          </svg>
        </div>
      </div>
    </div>

    <div class="relative h-[400px] border-0">
      <BarChart :data="computedChartData" :options="chartOptions" />
    </div>
  </div>
</template>

<script>
import {
  Chart as ChartJS,
  Title,
  Tooltip,
  Legend,
  BarElement,
  CategoryScale,
  LinearScale,
} from 'chart.js'
import ChartDataLabels from 'chartjs-plugin-datalabels'
import { Bar } from 'vue-chartjs'
import { useDashboardStore } from '@/stores/dashboard'
import { storeToRefs } from 'pinia'
import { computed, ref } from 'vue'

ChartJS.register(
  Title,
  Tooltip,
  Legend,
  BarElement,
  CategoryScale,
  LinearScale,
  ChartDataLabels
)

export default {
  name: 'AnalyticsChart',
  components: {
    BarChart: Bar,
  },
  setup() {
    const dashboardStore = useDashboardStore()
    const { allBookings } = storeToRefs(dashboardStore)
    const selectedOption = ref('month')

    const groupBy = (items, keyFn) => {
      return items.reduce((acc, item) => {
        const key = keyFn(item)
        acc[key] = acc[key] || []
        acc[key].push(item)
        return acc
      }, {})
    }

const computedChartData = computed(() => {
  if (!allBookings.value.length) return { labels: [], datasets: [] }

  const bookings = allBookings.value.map((b) => ({
    ...b,
    dateObj: new Date(`${b.date}T${b.time}`),
  }))

  let grouped = {}
  let labels = []

  switch (selectedOption.value) {
    case 'day':
      grouped = groupBy(bookings, (b) => b.dateObj.toISOString().slice(0, 10))
      break
    case 'week':
      grouped = groupBy(bookings, (b) => {
        const d = new Date(b.dateObj)
        const week = Math.ceil(d.getDate() / 7)
        return `${d.getFullYear()}-W${week}`
      })
      break
    case 'month':
      grouped = groupBy(bookings, (b) => {
        const d = b.dateObj
        return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`
      })
      break
    case 'year':
      grouped = groupBy(bookings, (b) => b.dateObj.getFullYear())
      break
  }

  labels = Object.keys(grouped).sort()

  const getCountByStatus = (status) =>
    labels.map((label) =>
      (grouped[label] || []).filter((b) => b.status.toLowerCase() === status).length
    )

  return {
    labels,
    datasets: [
      {
        label: 'Approved',
        data: getCountByStatus('approved'),
        backgroundColor: (context) => {
          const ctx = context.chart.ctx
          const gradient = ctx.createLinearGradient(0, 0, 0, 300)
          gradient.addColorStop(0, '#7c3aed')
          gradient.addColorStop(1, '#a78bfa')
          return gradient
        },
        borderRadius: 10,
        barThickness: 28,
      },
      {
        label: 'Declined',
        data: getCountByStatus('declined'),
        backgroundColor: (context) => {
          const ctx = context.chart.ctx
          const gradient = ctx.createLinearGradient(0, 0, 0, 300)
          gradient.addColorStop(0, '#ef4444')
          gradient.addColorStop(1, '#f87171')
          return gradient
        },
        borderRadius: 10,
        barThickness: 28,
      },
      {
        label: 'Pending',
        data: getCountByStatus('pending'),
        backgroundColor: (context) => {
          const ctx = context.chart.ctx
          const gradient = ctx.createLinearGradient(0, 0, 0, 300)
          gradient.addColorStop(0, '#10b981')
          gradient.addColorStop(1, '#6ee7b7')
          return gradient
        },
        borderRadius: 10,
        barThickness: 28,
      },
    ],
  }
})

const chartOptions = {
  responsive: true,
  maintainAspectRatio: false,
  animation: {
    duration: 800,
    easing: 'easeOutQuart',
  },
  plugins: {
    legend: {
      position: 'bottom',
      labels: {
        boxWidth: 16,
        boxHeight: 16,
        padding: 20,
        color: '#4B5563',
      },
    },
    datalabels: {
      color: '#111827',
      font: {
        size: 13,
        weight: 'bold',
      },
      anchor: 'end',
      align: 'top',
      formatter: (value) => (value > 0 ? value : ''),
    },
  },
  scales: {
    y: {
      beginAtZero: true,
      grid: {
        color: '#E5E7EB',
      },
      ticks: {
        stepSize: 1,
        color: '#6B7280',
        font: {
          size: 12,
        },
      },
    },
    x: {
      grid: {
        display: false,
      },
      ticks: {
        color: '#6B7280',
        font: {
          size: 12,
        },
      },
    },
  },
}


    return {
      selectedOption,
      computedChartData,
      chartOptions,
    }
  },
}
</script>
