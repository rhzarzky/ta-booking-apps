import api from './api'

export const bookingApi = {
  async getUserBookings() {
    try {
      const response = await api.get('/user/booking')
      return response.data.services
    } catch (error) {
      console.error('Failed to fetch user bookings:', error)
      throw error
    }
  },

  async getBookingDetail(id) {
    try {
      const response = await api.get(`/booking/${id}`)
      return response.data
    } catch (error) {
      console.error(`Failed to fetch booking detail (id: ${id}):`, error)
      throw error
    }
  },

  async completeBooking(id) {
    try {
      const response = await api.post(`/booking/${id}/complete`)
      return response.data.data
    } catch (error) {
      console.error(`bookingApi: Failed to complete booking (id: ${id}):`, error.response || error.message || error); // Log error lebih detail
      throw error
    }
  },

  async submitReview(id, reviewData) {
    try {
      const response = await api.post(`/booking/${id}/review`, reviewData)
      return response.data.data
    } catch (error) {
      console.error(`Failed to submit review for booking (id: ${id}):`, error)
      throw error
    }
  },

  // Cek apakah booking bisa direview
  async canReview(id) {
    try {
      const response = await api.get(`/booking/${id}/can-review`)
      return response.data.data
    } catch (error) {
      console.error(`Failed to check review permission (id: ${id}):`, error)
      throw error
    }
  },

  // Ambil review dari booking tertentu
  async getReview(id) {
    try {
      const response = await api.get(`/booking/${id}/review`)
      return response.data.data
    } catch (error) {
      console.error(`Failed to get review for booking (id: ${id}):`, error)
      throw error
    }
  },

  // Cek status selesai dari booking
  async getCompletionStatus(id) {
    try {
      const response = await api.get(`/booking/${id}/completion-status`)
      return response.data.data
    } catch (error) {
      console.error(`Failed to get completion status for booking (id: ${id}):`, error)
      throw error
    }
  },


  // Ambil semua review milik user login
  async getUserReviews() {
    try {
      const response = await api.get(`/user/reviews`)
      return response.data.data
    } catch (error) {
      console.error(`Failed to get user reviews:`, error)
      throw error
    }
  },
}
