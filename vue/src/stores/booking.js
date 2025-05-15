import { defineStore } from 'pinia';
import { bookingApi } from '@/api/booking-api';

export const useBookingStore = defineStore('booking', {
  state: () => ({
    bookingsByStatus: {},
    bookingDetail: null,
    loading: false,
    error: null
  }),

  actions: {
    async fetchUserBookings() {
      this.loading = true;
      this.error = null;

      try {
        const services = await bookingApi.getUserBookings();
        this.bookingsByStatus = services || {};
      } catch (err) {
        this.error = 'Gagal memuat data booking.';
        this.bookingsByStatus = {};
        console.error(err);
      } finally {
        this.loading = false;
      }
    },

    async fetchBookingDetail(id) {
      this.loading = true;
      this.error = null;

      try {
        const detail = await bookingApi.getBookingDetail(id);
        this.bookingDetail = detail?.service || null;
        if (!this.bookingDetail) {
          this.error = 'Detail booking tidak ditemukan.';
        }
      } catch (err) {
        this.error = 'Gagal memuat detail booking.';
        this.bookingDetail = null;
        console.error(err);
      } finally {
        this.loading = false;
      }
    },

    clearBookingDetail() {
      this.bookingDetail = null;
    }
  }
});
