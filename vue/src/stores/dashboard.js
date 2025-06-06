import { defineStore } from 'pinia'
import { bookingApi } from '@/api/booking-api'

export const useDashboardStore = defineStore('dashboard', {
  state: () => ({
    summary: {
      pending: 0,
      approved: 0,
      declined: 0,
      completed: 0,
    },
    latestBookings: [],
    allBookings: [],
    loading: false,
    error: null,
  }),

  actions: {
    async fetchDashboardData() {
      this.loading = true
      this.error = null

      try {
        const services = await bookingApi.getUserBookings()

        const approved = services.Approved || []
        const pending = services.Pending || []
        const declined = services.Declined || []
        const completed = services.Completed || []

        // Simpan jumlah status
        this.summary = {
          approved: approved.length,
          pending: pending.length,
          declined: declined.length,
          completed: completed.length,
        }

        // Gabungkan semua bookings
        const allBookings = [...approved, ...pending, ...declined, ...completed]
        this.allBookings = allBookings

        // Urutkan dari ID terbesar ke terkecil
        const sorted = allBookings.sort((a, b) => b.id_booking - a.id_booking)

        // Ambil 5 booking terbaru
        this.latestBookings = sorted.slice(0, 5).map((booking, index) => ({
          ...booking,
          displayNo: index + 1,
          displayDateTime: `${booking.date} ${booking.time}`,
        }))
      } catch (error) {
        this.error = 'Gagal memuat data dashboard.'
        console.error('Error fetching dashboard data:', error)
      } finally {
        this.loading = false
      }
    },
  },
})
