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
    </div>

    <!-- Chart -->
    <div class="relative h-[400px] border-0">
      <LineChart :data="computedChartData" :options="chartOptions" />
    </div>
  </div>
</template>

<script>
import {
  Chart as ChartJS,
  Title,
  Tooltip,
  Legend,
  LineElement,
  CategoryScale,
  LinearScale,
  PointElement,
  Filler,
} from 'chart.js'
// import ChartDataLabels from 'chartjs-plugin-datalabels'

import { Line as LineChart } from 'vue-chartjs'
import ChartDataLabels from 'chartjs-plugin-datalabels';

ChartJS.register(
  Title,
  Tooltip,
  Legend,
  LineElement,
  CategoryScale,
  LinearScale,
  PointElement,
  Filler,
  ChartDataLabels,
)

export default {
  name: 'AnalyticsChart',
  components: {
    LineChart,
  },
  data() {
    return {
      selectedOption: 'month',
      datasets: {
        day: {
          labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
          data: [
            [10, 20, 15, 30, 25, 40, 35], // Approved
            [5, 7, 6, 5, 4, 3, 2], // Declined
            [50, 45, 40, 30, 20, 10, 5], // Under Review
          ],
        },
        week: {
          labels: ['Week 1', 'Week 2', 'Week 3', 'Week 4'],
          data: [
            [100, 150, 200, 250],
            [30, 25, 20, 15],
            [300, 250, 200, 150],
          ],
        },
        month: {
          labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
          data: [
            [30.72, 70, 200, 400, 800, 134],
            [412, 390, 370, 350, 340, 124],
            [4135, 3000, 2000, 1000, 500, 30],
          ],
        },
        year: {
          labels: ['2020', '2021', '2022', '2023', '2024'],
          data: [
            [1000, 2000, 2500, 3000, 4000],
            [800, 700, 600, 500, 400],
            [6000, 5000, 4000, 3000, 2000],
          ],
        },
      },
      chartOptions: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            position: 'bottom',
            labels: {
              color: '#333',
              font: {
                size: 13,
                weight: '500',
              },
              usePointStyle: true,
              pointStyle: 'circle',
              padding: 20,
            },
          },
          tooltip: {
            backgroundColor: '#fff',
            titleColor: '#333',
            bodyColor: '#333',
            borderColor: '#ccc',
            borderWidth: 1,
            titleFont: { weight: '600' },
            bodyFont: { weight: '500' },
            padding: 10,
          },
          datalabels: {
            color: '#333', // Label color
            font: {
              size: 12,
            },
            padding: 0,
            anchor: 'end', // Position of the label (at the end of the line)
            align: 'end', // Align the label at the end of the line
            offset: 1, // Space between the point and label
            display: (context) => {
              const index = context.dataIndex
              const total = context.dataset.data.length
              // Show label on first and last point only
              return index === 0 || index === total - 1
            },
          },
        },
        elements: {
          line: {
            borderWidth: 1,
            borderCapStyle: 'round',
            display: false,
          },
        },
        scales: {
          x: {
            display: false,
            ticks: {
              color: '#666',
              font: {
                size: 12,
              },
              display: false,
            },
            grid: {
              display: false
            },
            offset: true,
          },
          y: {
            display: false,
            ticks: {
              color: '#666',
              font: {
                size: 12,
              },
              display: false,
            },
            grid: {
              display: false,
            },
          },
        },
        layout: {
          padding: {
            top: 20, // Menambah ruang di bagian atas chart
            bottom: 40, // Menambah ruang di bagian bawah chart agar teks tidak tertutup
          },
        },
      },
    }
  },
  computed: {
    computedChartData() {
      const selected = this.datasets[this.selectedOption]
      return {
        labels: selected.labels,
        datasets: [
          {
            label: 'Approved',
            data: selected.data[0],
            borderColor: '#7B61FF',
            backgroundColor: 'rgba(123, 97, 255, 0.15)',
            tension: 0.5,
            fill: false,
            pointBackgroundColor: '#7B61FF',
            pointBorderColor: '#fff',
            pointRadius: (context) => {
              const index = context.dataIndex
              const total = context.dataset.data.length
              return index === 0 || index === total - 1 ? 5 : 0 // Menampilkan titik hanya di ujung
            },
            pointHoverRadius: 8,
            pointBorderWidth: 2,
          },
          {
            label: 'Declined',
            data: selected.data[1],
            borderColor: '#FF6C6C',
            backgroundColor: 'rgba(255, 108, 108, 0.1)',
            tension: 0.5,
            fill: false,
            pointBackgroundColor: '#FF6C6C',
            pointBorderColor: '#fff',
            pointRadius: (context) => {
              const index = context.dataIndex
              const total = context.dataset.data.length
              return index === 0 || index === total - 1 ? 5 : 0 // Menampilkan titik hanya di ujung
            },
            pointHoverRadius: 8,
            pointBorderWidth: 2,
          },
          {
            label: 'Under Review',
            data: selected.data[2],
            borderColor: '#00C2FF',
            backgroundColor: 'rgba(0, 194, 255, 0.1)',
            tension: 0.5,
            fill: false,
            pointBackgroundColor: '#00C2FF',
            pointBorderColor: '#fff',
            pointRadius: (context) => {
              const index = context.dataIndex
              const total = context.dataset.data.length
              return index === 0 || index === total - 1 ? 5 : 0 // Menampilkan titik hanya di ujung
            },
            pointHoverRadius: 8,
            pointBorderWidth: 2,
          },
        ],
      }
    },
  },
}
</script>
