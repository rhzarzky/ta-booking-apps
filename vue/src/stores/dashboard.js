import { defineStore } from 'pinia'
import { bookingApi } from '@/api/booking-api' // Pastikan path ini benar

export const useDashboardStore = defineStore('dashboard', {
  state: () => ({
    summary: {
      pending: 0,
      approved: 0,
      declined: 0,
      completed: 0,
      total: 0, 
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
        const response = await bookingApi.getUserBookings()

        console.log('[Dashboard] Full API response from getUserBookings:', response)

        const services = response.services || {}

        console.log('[Dashboard] Parsed services:', services)

        const approved = services.Approved || []
        const pending = services.Pending || []
        const declined = services.Declined || []
        const completed = services.Completed || []

        // const totalCount = pending.length + approved.length + declined.length + completed.length;
        const totalCount = services.length
        
        console.log('[Dashboard] Counts →',
          'Pending:', pending.length,
          'Approved:', approved.length,
          'Declined:', declined.length,
          'Completed:', completed.length,
          'Total:', totalCount
        )

        this.summary = {
          approved: approved.length,
          pending: pending.length,
          declined: declined.length,
          completed: completed.length,
          total: totalCount, 
        }

        this.allBookings = [...approved, ...pending, ...declined, ...completed]

        // Pastikan pengurutan berdasarkan ID booking yang bersifat unik dan kronologis
        const sorted = this.allBookings.sort((a, b) => b.id_booking - a.id_booking)

        this.latestBookings = sorted.slice(0, 5).map((booking, index) => {
          const dateTimeString = `${booking.date}T${booking.time}:00`; 
          const bookingDateObj = new Date(dateTimeString);

          const options = { year: 'numeric', month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit', hour12: true };
          const formattedDateTime = bookingDateObj.toLocaleDateString('en-US', options);


          return {
            ...booking,
            displayNo: index + 1,
            displayDateTime: formattedDateTime, // Gunakan format yang sudah diolah
          };
        });

        console.log('[Dashboard] Latest bookings to display:', this.latestBookings)
      } catch (error) {
        this.error = 'Gagal memuat data dashboard.'
        console.error('[Dashboard] Error fetching dashboard data:', error)
      } finally {
        this.loading = false
      }
    }
  },
})