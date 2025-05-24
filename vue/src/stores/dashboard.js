import { defineStore } from 'pinia';
import { bookingApi } from '@/api/booking-api';

export const useDashboardStore = defineStore('dashboard', {
  state: () => ({
    summary: {
      pending: 0,
      approved: 0,
      declined: 0
    },
    latestBookings: [],
    loading: false,
    error: null
  }),

  actions: {
    async fetchDashboardData() {
      this.loading = true;
      this.error = null;

      try {
        const services = await bookingApi.getUserBookings();
        const allBookings = services || [];

        const summary = {
          pending: 0,
          approved: 0,
          declined: 0
        };

        allBookings.forEach((booking) => {
          const status = booking.status?.toLowerCase();
          if (status === 'pending') summary.pending++;
          else if (status === 'approved') summary.approved++;
          else if (status === 'declined') summary.declined++;
        });

        // Ambil 10 booking terbaru berdasarkan tanggal
        const sortedBookings = allBookings
          .slice()
          .sort((a, b) => new Date(b.created_at) - new Date(a.created_at))
          .slice(0, 10);

        this.summary = summary;
        this.latestBookings = sortedBookings;

      } catch (err) {
        this.error = 'Gagal memuat data dashboard.';
        this.summary = { pending: 0, approved: 0, declined: 0 };
        this.latestBookings = [];
        console.error(err);
      } finally {
        this.loading = false;
      }
    }
  }
});
