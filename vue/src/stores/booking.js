// src/stores/booking.js
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
        // ✅ Ambil seluruh objek, karena services ada di dalam response.data
        // Perhatikan bahwa response.data adalah { status: "success", services: {...} }
        // Jadi, akses langsung response.data
        this.bookingsByStatus = response.services || {}
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
        await this.fetchUserReviews() // Pastikan user reviews diperbarui
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
        const response = await bookingApi.getUserReviews()
        // Pastikan Anda mengakses properti 'reviews' dari respons API
        this.userReviews = response || [] // Respons API Anda sudah langsung berupa array reviews
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
      // Perbaikan di sini: Akses review.service?.id sesuai struktur JSON review
      return state.userReviews.some(review => review.service?.id === serviceId)
    }
  }
})