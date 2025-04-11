<template>
    <div class="bg-white p-6 rounded-lg shadow mb-8">
      <div class="flex justify-between items-center mb-4">
        <h2 class="text-xl font-bold">Analytics</h2>
        <select class="border rounded px-2 py-1 text-sm">
          <option>Month</option>
          <option>Week</option>
        </select>
      </div>
      <Line :data="chartData" :options="chartOptions" />
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
  } from 'chart.js'
  import { Line } from 'vue-chartjs'
  
  ChartJS.register(Title, Tooltip, Legend, LineElement, CategoryScale, LinearScale, PointElement)
  
  export default {
    name: 'AnalyticsChart',
    components: {
      Line,
    },
    data() {
      return {
        chartData: {
          labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
          datasets: [
            {
              label: 'Approved',
              data: [30, 70, 200, 400, 800, 1340],
              fill: false,
              borderColor: '#7f00ff',
              tension: 0.4,
              pointBackgroundColor: '#7f00ff',
            },
            {
              label: 'Declined',
              data: [400, 390, 370, 350, 340, 134],
              fill: false,
              borderColor: '#ff6b6b',
              tension: 0.4,
              pointBackgroundColor: '#ff6b6b',
            },
            {
              label: 'Under Review',
              data: [4135, 3000, 2000, 1000, 500, 34],
              fill: false,
              borderColor: '#3c8ce7',
              tension: 0.4,
              pointBackgroundColor: '#3c8ce7',
            },
          ],
        },
        chartOptions: {
          responsive: true,
          plugins: {
            legend: {
              labels: {
                color: '#333',
                font: {
                  size: 12,
                },
              },
            },
          },
          scales: {
            y: {
              ticks: {
                color: '#555',
              },
            },
            x: {
              ticks: {
                color: '#555',
              },
            },
          },
        },
      }
    },
  }
  </script>
  