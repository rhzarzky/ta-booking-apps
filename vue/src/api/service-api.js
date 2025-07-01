// api/service-api.js
import api from './api'

export const serviceApi = {
  async fetchServices() {
    try {
      const response = await api.get('/service')
      return response.data.services
    } catch (error) {
      console.error('Failed to fetch services:', error)
      throw error
    }
  },

  async fetchServiceById(id) {
    try {
      const response = await api.get(`/service/${id}`)
      return response.data.service
    } catch (error) {
      console.error(`Failed to fetch service by id ${id}:`, error)
      throw error
    }
  },

  async bookService(id, payload) {
    try {
      const response = await api.post(`/service/${id}/book`, payload)
      return response.data.service
    } catch (error) {
      if (error.response) {
        console.error('Validation errors:', error.response.data.errors)
      }
      console.error(`Failed to book service ${id}:`, error)
      throw error
    }
  },

  async fetchServiceReviews(id) {
    try {
      const response = await api.get(`/service/${id}/reviews`)
      return response.data.reviews || []
    } catch (error) {
      console.error(`Failed to fetch reviews for service ${id}:`, error)
      throw error
    }
  },
}
