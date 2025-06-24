import api from './api'

export const bookingApi = {
  async getUserBookings() {
    try {
      const response = await api.get('/user/booking')
      return response.data || {} // ⬅️ Ambil seluruh objek, karena services ada di dalam response.data
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

  async markBookingAsCompleted(id) {
    try {
      const response = await api.post(`/booking/${id}/complete`)
      return response.data
    } catch (error) {
      console.error(`bookingApi: Failed to mark booking ${id} as completed:`, error.response || error.message || error)
      throw error
    }
  },

  async submitReview(serviceId, payload) {
    try {
      const response = await api.post(`/service/${serviceId}/review`, payload)
      return response.data
    } catch (error) {
      console.error(`bookingApi: Failed to submit review for service ${serviceId}:`, error.response || error.message || error)
      throw error
    }
  },

  async getServiceReviews(serviceId) {
    try {
      const response = await api.get(`/service/${serviceId}/reviews`)
      return response.data.reviews
    } catch (error) {
      console.error(`bookingApi: Failed to fetch reviews for service ${serviceId}:`, error.response || error.message || error)
      throw error
    }
  },

  async getUserReviews() {
    try {
      const response = await api.get('/user/reviews')
      return response.data.reviews
    } catch (error) {
      console.error('bookingApi: Failed to fetch user reviews:', error.response || error.message || error)
      throw error
    }
  }
}
