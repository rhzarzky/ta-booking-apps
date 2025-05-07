import { defineStore } from 'pinia'
import axios from 'axios'

export const useServicesStore = defineStore('services', {
  state: () => ({
    services: [],
    isLoading: false,
    error: null,
    notification: {
      show: false,
      message: '',
      type: 'success', 
    },
  }),

  actions: {
    async fetchServices() {
      this.isLoading = true
      this.error = null

      try {
        // Ensure baseURL is set correctly in Axios configuration
        const response = await axios.get('/service') 

        // Check if response has valid status
        if (response.data.status === 'success') {
          this.services = response.data.services
        } else {
          throw new Error(response.data.message || 'Failed to fetch services')
        }
      } catch (err) {
        // Set error message from exception or fallback to a default
        this.error = err.message || 'An unexpected error occurred'
        this.showNotification(this.error, 'error')
      } finally {
        this.isLoading = false
      }
    },

    showNotification(message, type = 'success') {
      this.notification.message = message
      this.notification.type = type
      this.notification.show = true

      // auto close after 3 seconds
      setTimeout(() => {
        this.notification.show = false
      }, 3000)
    },
  },
})
