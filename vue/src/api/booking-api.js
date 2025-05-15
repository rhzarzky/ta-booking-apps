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
  }
}
