<template>
  <div class="bg-white p-6 rounded-2xl shadow-lg mb-8">
    <div class="flex flex-col sm:flex-row justify-between items-center mb-6 gap-4">
      <h2 class="text-2xl font-bold text-gray-900">Booking Analytics</h2>

      <div class="flex items-center gap-4 flex-wrap">
        <div class="relative">
          <select
            v-model="selectedYear"
            @change="handleYearChange"
            class="appearance-none border border-gray-300 rounded-lg px-5 py-2 text-sm text-gray-700 bg-white shadow-sm focus:outline-none focus:ring-2 focus:ring-indigo-500 pr-8 cursor-pointer"
          >
            <option v-for="year in availableYears" :key="year" :value="year">
              {{ year }}
            </option>
          </select>
          <div
            class="pointer-events-none absolute inset-y-0 right-3 flex items-center text-gray-500"
          >
            <svg
              class="w-4 h-4"
              fill="none"
              stroke="currentColor"
              stroke-width="2"
              viewBox="0 0 24 24"
            >
              <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7" />
            </svg>
          </div>
        </div>

        <div class="relative">
          <select
            v-model="selectedMonth"
            class="appearance-none border border-gray-300 rounded-lg px-5 py-2 text-sm text-gray-700 bg-white shadow-sm focus:outline-none focus:ring-2 focus:ring-indigo-500 pr-8 cursor-pointer"
          >
            <option value="all">All Months</option>
            <option v-for="(monthName, index) in monthNames" :key="index" :value="index + 1">
              {{ monthName }}
            </option>
          </select>
          <div
            class="pointer-events-none absolute inset-y-0 right-3 flex items-center text-gray-500"
          >
            <svg
              class="w-4 h-4"
              fill="none"
              stroke="currentColor"
              stroke-width="2"
              viewBox="0 0 24 24"
            >
              <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7" />
            </svg>
          </div>
        </div>

        <button
          @click="clearFilters"
          class="px-4 py-2 rounded-lg bg-gray-200 text-gray-700 text-sm font-medium hover:bg-gray-300 focus:outline-none focus:ring-2 focus:ring-gray-400 transition-colors duration-200 ease-in-out"
        >
          Clear Filters
        </button>
      </div>
    </div>

    <div class="relative h-[400px]">
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
import { computed, ref, onMounted } from 'vue'

ChartJS.register(Title, Tooltip, Legend, BarElement, CategoryScale, LinearScale, ChartDataLabels)

export default {
  name: 'AnalyticsChart',
  components: {
    BarChart: Bar,
  },
  setup() {
    const dashboardStore = useDashboardStore()
    const { allBookings } = storeToRefs(dashboardStore)

    const currentYear = new Date().getFullYear()
    const currentMonth = new Date().getMonth() + 1

    const selectedYear = ref(currentYear)
    const selectedMonth = ref('all')

    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ]

    const getDaysInMonth = (year, month) => {
      return new Date(year, month, 0).getDate()
    }

    const groupBy = (items, keyFn) => {
      return items.reduce((acc, item) => {
        const key = keyFn(item)
        acc[key] = acc[key] || []
        acc[key].push(item)
        return acc
      }, {})
    }

    const availableYears = computed(() => {
      const years = new Set()
      allBookings.value.forEach((b) => {
        const date = new Date(b.date)
        years.add(date.getFullYear())
      })
      years.add(currentYear)
      return Array.from(years).sort((a, b) => b - a)
    })

    const handleYearChange = () => {
      selectedMonth.value = 'all'
    }

    const clearFilters = () => {
      selectedYear.value = currentYear
      selectedMonth.value = 'all'
    }

    const computedChartData = computed(() => {
      if (!allBookings.value.length) return { labels: [], datasets: [] }

      const filteredBookings = allBookings.value.filter((b) => {
        const bookingDate = new Date(b.date)
        const bookingYear = bookingDate.getFullYear()
        const bookingMonth = bookingDate.getMonth() + 1

        const isMatchingYear = bookingYear === selectedYear.value
        const isMatchingMonth =
          selectedMonth.value === 'all' || bookingMonth === selectedMonth.value

        return isMatchingYear && isMatchingMonth
      })

      let labels = []
      let groupedByTimePeriod = {} // Renamed for clarity on what's being grouped

      if (selectedMonth.value === 'all') {
        labels = monthNames
        groupedByTimePeriod = groupBy(filteredBookings, (b) => new Date(b.date).getMonth())

        // Data array will be 12 elements (for 12 months)
        const getCountByStatus = (status) => {
          return Array.from(
            { length: 12 },
            (_, monthIndex) =>
              (groupedByTimePeriod[monthIndex] || []).filter(
                (b) => b.status.toLowerCase() === status,
              ).length,
          )
        }

        return {
          labels,
          datasets: [
            {
              label: 'Pending',
              data: getCountByStatus('pending'),
              backgroundColor: (ctx) => {
                const g = ctx.chart.ctx.createLinearGradient(0, 0, 0, 300)
                g.addColorStop(0, '#84CC16')
                g.addColorStop(1, '#D9F99D')
                return g
              },
              borderRadius: 8,
              barThickness: 24,
              categoryPercentage: 0.7,
              barPercentage: 0.8,
            },
            {
              label: 'Approved',
              data: getCountByStatus('approved'),
              backgroundColor: (ctx) => {
                const g = ctx.chart.ctx.createLinearGradient(0, 0, 0, 300)
                g.addColorStop(0, '#9F7AEA')
                g.addColorStop(1, '#C4B5FD')
                return g
              },
              borderRadius: 8,
              barThickness: 24,
              categoryPercentage: 0.7,
              barPercentage: 0.8,
            },
            {
              label: 'Completed',
              data: getCountByStatus('completed'),
              backgroundColor: (ctx) => {
                const g = ctx.chart.ctx.createLinearGradient(0, 0, 0, 300)
                g.addColorStop(0, '#3b82f6') // biru terang
                g.addColorStop(1, '#1e40af') // biru tua
                return g
              },
              borderRadius: 8,
              barThickness: 24,
              categoryPercentage: 0.7,
              barPercentage: 0.8,
            },
            {
              label: 'Declined',
              data: getCountByStatus('declined'),
              backgroundColor: (ctx) => {
                const g = ctx.chart.ctx.createLinearGradient(0, 0, 0, 300)
                g.addColorStop(0, '#F87171')
                g.addColorStop(1, '#FECACA')
                return g
              },
              borderRadius: 8,
              barThickness: 24,
              categoryPercentage: 0.7,
              barPercentage: 0.8,
            },
          ],
        }
      } else {
        // Daily breakdown for the selected month and year
        groupedByTimePeriod = groupBy(filteredBookings, (b) => new Date(b.date).getDate())

        // Get unique days that actually have bookings
        const uniqueDaysWithBookings = Object.keys(groupedByTimePeriod)
          .map(Number)
          .sort((a, b) => a - b)
        labels = uniqueDaysWithBookings.map((day) => day.toString())

        const getCountByStatus = (status) => {
          return uniqueDaysWithBookings.map(
            (day) =>
              (groupedByTimePeriod[day] || []).filter((b) => b.status.toLowerCase() === status)
                .length,
          )
        }

        return {
          labels,
          datasets: [
            {
              label: 'Pending',
              data: getCountByStatus('pending'),
              backgroundColor: (ctx) => {
                const g = ctx.chart.ctx.createLinearGradient(0, 0, 0, 300)
                g.addColorStop(0, '#84CC16')
                g.addColorStop(1, '#D9F99D')
                return g
              },
              borderRadius: 8,
              barThickness: 24,
              categoryPercentage: 0.7,
              barPercentage: 0.8,
            },
            {
              label: 'Approved',
              data: getCountByStatus('approved'),
              backgroundColor: (ctx) => {
                const g = ctx.chart.ctx.createLinearGradient(0, 0, 0, 300)
                g.addColorStop(0, '#9F7AEA')
                g.addColorStop(1, '#C4B5FD')
                return g
              },
              borderRadius: 8,
              barThickness: 24,
              categoryPercentage: 0.7,
              barPercentage: 0.8,
            },

            {
              label: 'Completed',
              data: getCountByStatus('completed'),
              backgroundColor: (ctx) => {
                const g = ctx.chart.ctx.createLinearGradient(0, 0, 0, 300)
                g.addColorStop(0, '#3b82f6')
                g.addColorStop(1, '#1e40af')
                return g
              },
              borderRadius: 8,
              barThickness: 24,
              categoryPercentage: 0.7,
              barPercentage: 0.8,
            },
            {
              label: 'Declined',
              data: getCountByStatus('declined'),
              backgroundColor: (ctx) => {
                const g = ctx.chart.ctx.createLinearGradient(0, 0, 0, 300)
                g.addColorStop(0, '#F87171')
                g.addColorStop(1, '#FECACA')
                return g
              },
              borderRadius: 8,
              barThickness: 24,
              categoryPercentage: 0.7,
              barPercentage: 0.8,
            },
          ],
        }
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
            color: '#4B5563', // gray-700
            font: {
              size: 13,
            },
          },
        },
        datalabels: {
          color: '#374151', // gray-700
          font: {
            size: 12,
            weight: 'bold',
          },
          anchor: 'end',
          align: 'top',
          offset: 4,
          formatter: (value) => (value > 0 ? value : ''),
        },
        tooltip: {
          backgroundColor: 'rgba(0, 0, 0, 0.7)',
          titleFont: { size: 14, weight: 'bold' },
          bodyFont: { size: 12 },
          padding: 10,
          cornerRadius: 6,
          // Custom tooltip to show full date for daily view
          callbacks: {
            title: function (context) {
              const labelIndex = context[0].dataIndex
              const chartLabels = context[0].chart.data.labels
              const selectedMonthVal = selectedMonth.value
              if (selectedMonthVal !== 'all' && chartLabels[labelIndex]) {
                // Reconstruct date for daily view tooltip
                const day = chartLabels[labelIndex]
                const month = monthNames[selectedMonthVal - 1] // Convert 1-indexed month to name
                const year = selectedYear.value
                return `${month} ${day}, ${year}`
              }
              return context[0].label // Default title for monthly view
            },
            label: function (context) {
              let label = context.dataset.label || ''
              if (label) {
                label += ': '
              }
              if (context.parsed.y !== null) {
                label += context.parsed.y
              }
              return label
            },
          },
        },
      },
      scales: {
        y: {
          beginAtZero: true,
          grid: {
            color: '#E5E7EB',
            drawBorder: false,
          },
          ticks: {
            stepSize: 1,
            color: '#6B7280',
            font: {
              size: 11,
            },
            callback: function (value) {
              if (Number.isInteger(value)) {
                return value
              }
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
              size: 11,
            },
            maxRotation: 45, // Rotate labels if they overlap
            minRotation: 0,
          },
        },
      },
    }

    onMounted(() => {
      // Data fetching assumed to be handled by useDashboardStore globally
    })

    return {
      selectedYear,
      selectedMonth,
      availableYears,
      monthNames,
      computedChartData,
      chartOptions,
      handleYearChange,
      clearFilters,
    }
  },
}
</script>
