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
          <div class="pointer-events-none absolute inset-y-0 right-3 flex items-center text-gray-500">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
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
          <div class="pointer-events-none absolute inset-y-0 right-3 flex items-center text-gray-500">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
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

    // Current year and month for default selection
    const currentYear = new Date().getFullYear();
    const currentMonth = new Date().getMonth() + 1; // getMonth() is 0-indexed

    const selectedYear = ref(currentYear);
    const selectedMonth = ref('all'); // Default to 'all' months

    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    // Helper to get number of days in a given month and year
    const getDaysInMonth = (year, month) => {
        return new Date(year, month, 0).getDate();
    };

    // Helper to group items by a key
    const groupBy = (items, keyFn) => {
      return items.reduce((acc, item) => {
        const key = keyFn(item)
        acc[key] = acc[key] || []
        acc[key].push(item)
        return acc
      }, {})
    }

    // Generate list of years from available data + current year
    const availableYears = computed(() => {
      const years = new Set();
      allBookings.value.forEach(b => {
        const date = new Date(b.date);
        years.add(date.getFullYear());
      });
      // Ensure current year is always an option
      years.add(currentYear);
      return Array.from(years).sort((a, b) => b - a); // Sort descending
    });

    const handleYearChange = () => {
      // When year changes, reset month to 'all'
      selectedMonth.value = 'all';
    };

    const clearFilters = () => {
      selectedYear.value = currentYear;
      selectedMonth.value = 'all';
    };

    const computedChartData = computed(() => {
      if (!allBookings.value.length) return { labels: [], datasets: [] };

      // Filter bookings by selected year and month
      const filteredBookings = allBookings.value.filter(b => {
        const bookingDate = new Date(b.date);
        const bookingYear = bookingDate.getFullYear();
        const bookingMonth = bookingDate.getMonth() + 1; // 1-indexed

        const isMatchingYear = bookingYear === selectedYear.value;
        const isMatchingMonth = selectedMonth.value === 'all' || bookingMonth === selectedMonth.value;

        return isMatchingYear && isMatchingMonth;
      });

      let labels = [];
      let grouped = {};

      if (selectedMonth.value === 'all') {
        // Show all 12 months for the selected year
        labels = monthNames; // Use full month names as labels
        grouped = groupBy(filteredBookings, (b) => {
          const d = new Date(b.date);
          return d.getMonth(); // Group by 0-indexed month for mapping to monthNames
        });

        // Ensure all 12 months are represented in the labels, even if no data
        const fullMonthLabels = Array.from({ length: 12 }, (_, i) => monthNames[i]);
        labels = fullMonthLabels;

      } else {
        // Show daily breakdown for the selected month and year
        const daysInSelectedMonth = getDaysInMonth(selectedYear.value, selectedMonth.value);
        labels = Array.from({ length: daysInSelectedMonth }, (_, i) => (i + 1).toString()); // Labels are '1', '2', ..., '31'

        grouped = groupBy(filteredBookings, (b) => {
          const d = new Date(b.date);
          return d.getDate(); // Group by day of the month (1-indexed)
        });
      }

      const getCountByStatus = (status) => {
        if (selectedMonth.value === 'all') {
          // For 'All Months' view, iterate through all 12 months (0-11)
          return Array.from({ length: 12 }, (_, monthIndex) =>
            (grouped[monthIndex] || []).filter((b) => b.status.toLowerCase() === status).length
          );
        } else {
          // For a specific month (daily breakdown), iterate through days of the month
          const daysInCurrentMonth = getDaysInMonth(selectedYear.value, selectedMonth.value);
          return Array.from({ length: daysInCurrentMonth }, (_, dayIndex) =>
            (grouped[dayIndex + 1] || []).filter((b) => b.status.toLowerCase() === status).length // dayIndex + 1 because day is 1-indexed
          );
        }
      };

      return {
        labels,
        datasets: [
          {
            label: 'Approved',
            data: getCountByStatus('approved'),
            backgroundColor: (context) => {
              const ctx = context.chart.ctx
              const gradient = ctx.createLinearGradient(0, 0, 0, 300)
              gradient.addColorStop(0, '#4CAF50') // Brighter green
              gradient.addColorStop(1, '#81C784') // Lighter green
              return gradient
            },
            borderRadius: 8,
            barThickness: 24,
            categoryPercentage: 0.7,
            barPercentage: 0.8,
          },
          {
            label: 'Declined',
            data: getCountByStatus('declined'),
            backgroundColor: (context) => {
              const ctx = context.chart.ctx
              const gradient = ctx.createLinearGradient(0, 0, 0, 300)
              gradient.addColorStop(0, '#F44336') // Brighter red
              gradient.addColorStop(1, '#EF9A9A') // Lighter red
              return gradient
            },
            borderRadius: 8,
            barThickness: 24,
            categoryPercentage: 0.7,
            barPercentage: 0.8,
          },
          {
            label: 'Pending',
            data: getCountByStatus('pending'),
            backgroundColor: (context) => {
              const ctx = context.chart.ctx
              const gradient = ctx.createLinearGradient(0, 0, 0, 300)
              gradient.addColorStop(0, '#FFC107') // Brighter amber
              gradient.addColorStop(1, '#FFEB3B') // Lighter amber
              return gradient
            },
            borderRadius: 8,
            barThickness: 24,
            categoryPercentage: 0.7,
            barPercentage: 0.8,
          },
        ],
      }
    });

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
          offset: 4, // slight offset from the bar
          formatter: (value) => (value > 0 ? value : ''), // Only show if value > 0
        },
        tooltip: {
          backgroundColor: 'rgba(0, 0, 0, 0.7)',
          titleFont: { size: 14, weight: 'bold' },
          bodyFont: { size: 12 },
          padding: 10,
          cornerRadius: 6,
        }
      },
      scales: {
        y: {
          beginAtZero: true,
          grid: {
            color: '#E5E7EB', // gray-200
            drawBorder: false,
          },
          ticks: {
            stepSize: 1,
            color: '#6B7280', // gray-500
            font: {
              size: 11,
            },
            // Ensure integer ticks
            callback: function(value) {
              if (Number.isInteger(value)) {
                return value;
              }
            }
          },
        },
        x: {
          grid: {
            display: false,
          },
          ticks: {
            color: '#6B7280', // gray-500
            font: {
              size: 11,
            },
          },
        },
      },
    }

    onMounted(() => {
        // No need to fetch data here, as useDashboardStore likely handles it globally
        // or you would fetch it in the parent component that uses this AnalyticsChart.
        // Assuming allBookings is already populated or will be.
    });


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

<style scoped>
/* Scoped styles for this component */
.bg-white {
  background-color: #ffffff;
}
.shadow-lg {
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
}
.rounded-2xl {
  border-radius: 1rem;
}
</style>