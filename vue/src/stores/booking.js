import { defineStore } from 'pinia';
import { bookingApi } from '@/api/booking-api';

export const useBookingStore = defineStore('booking', {
  state: () => ({
    bookingsByStatus: {}, // ex: { Pending: [...], Completed: [...] }
    bookingDetail: null,
    loading: false,
    error: null,
    userReviews: [],
    serviceReviews: [],
    completionStatus: null,
    canSubmitReview: false,
  }),

  actions: {
    async fetchUserBookings() {
      this.loading = true;
      this.error = null;
      try {
        const response = await bookingApi.getUserBookings()
        this.bookingsByStatus = response.services || {} // ✅ Ambil key "services" dari API response
      } catch (err) {
        this.error = 'Gagal memuat data booking.'
        this.bookingsByStatus = {}
        console.error(err)
      } finally {
        this.loading = false
      }
    },

    async fetchBookingDetail(id) {
      this.loading = true
      this.error = null
      try {
        const detail = await bookingApi.getBookingDetail(id)
        this.bookingDetail = detail
        this.canSubmitReview = detail?.status === 'Completed'

        if (detail?.service?.id) {
          await this.fetchServiceReviews(detail.service.id)
        }
      } catch (err) {
        this.error = 'Gagal memuat detail booking.'
        this.bookingDetail = null
        console.error(err)
      } finally {
        this.loading = false
      }
    },

    async completeBooking(id) {
      this.loading = true
      this.error = null
      this.completionStatus = null
      try {
        const response = await bookingApi.markBookingAsCompleted(id)
        this.completionStatus = 'success'
        await this.fetchUserBookings()

        if (this.bookingDetail?.id_booking === id) {
          await this.fetchBookingDetail(id)
        }

        return response
      } catch (error) {
        this.error = 'Gagal menyelesaikan booking.'
        this.completionStatus = 'error'
        console.error('Pinia Store: Error completing booking:', error)
        throw error
      } finally {
        this.loading = false
      }
    },

    async submitReview(serviceId, payload) {
      this.loading = true
      this.error = null
      try {
        const response = await bookingApi.submitReview(serviceId, payload)
        await this.fetchServiceReviews(serviceId)
        await this.fetchUserReviews()
        this.canSubmitReview = false
        return response
      } catch (error) {
        this.error = 'Gagal mengirimkan review.'
        console.error('Pinia Store: Error submitting review:', error)
        throw error
      } finally {
        this.loading = false
      }
    },

    async fetchServiceReviews(serviceId) {
      this.loading = true
      this.error = null
      try {
        const reviews = await bookingApi.getServiceReviews(serviceId)
        this.serviceReviews = reviews || []
      } catch (error) {
        this.error = 'Gagal memuat review layanan.'
        this.serviceReviews = []
        console.error(error)
      } finally {
        this.loading = false
      }
    },

    async fetchUserReviews() {
      this.loading = true
      this.error = null
      try {
        const reviews = await bookingApi.getUserReviews()
        this.userReviews = reviews || []
      } catch (error) {
        this.error = 'Gagal memuat review pengguna.'
        this.userReviews = []
        console.error(error)
      } finally {
        this.loading = false
      }
    },
  },

  getters: {
    getBookingById: (state) => (id) => {
      for (const status in state.bookingsByStatus) {
        const found = state.bookingsByStatus[status].find(b => b.id_booking === id)
        if (found) return found
      }
      return null
    },

    getReviewsForService: (state) => (serviceId) => {
      return state.serviceReviews.filter(review => review.service_id === serviceId)
    },

    hasUserReviewedService: (state) => (serviceId) => {
      return state.userReviews.some(review => review.service?.id === serviceId)
    },

    // Getter baru untuk booking aktif (Pending dan Approved)
    activeBookings: (state) => {
      const active = [];
      if (state.bookingsByStatus['Pending']) {
        active.push(...state.bookingsByStatus['Pending']);
      }
      if (state.bookingsByStatus['Approved']) {
        active.push(...state.bookingsByStatus['Approved']);
      }
      return active.sort((a, b) => b.id_booking - a.id_booking);
    },

    // Getter baru untuk riwayat booking (Completed dan Declined)
    historicalBookings: (state) => {
      const history = [];
      if (state.bookingsByStatus['Completed']) {
        history.push(...state.bookingsByStatus['Completed']);
      }
      if (state.bookingsByStatus['Declined']) {
        history.push(...state.bookingsByStatus['Declined']);
      }
      return history.sort((a, b) => b.id_booking - a.id_booking);
    },
  }
})