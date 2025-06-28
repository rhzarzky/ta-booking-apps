// stores/service.js
import { defineStore } from 'pinia'
import { ref } from 'vue'
import { serviceApi } from '@/api/service-api'

export const useServiceStore = defineStore('service', () => {
  const services = ref([])
  const service = ref(null)
  const reviews = ref([])
  const loading = ref(false)

  const fetchServices = async () => {
    loading.value = true
    try {
      services.value = await serviceApi.fetchServices()
    } catch (error) {
      console.error('Failed to fetch services:', error)
    } finally {
      loading.value = false
    }
  }

  const fetchServiceById = async (id) => {
    loading.value = true
    try {
      service.value = await serviceApi.fetchServiceById(id)
    } catch (error) {
      console.error(`Failed to fetch service by id ${id}:`, error)
    } finally {
      loading.value = false
    }
  }

  const fetchServiceReviews = async (id) => {
    try {
      reviews.value = await serviceApi.fetchServiceReviews(id)
    } catch (error) {
      console.error('Failed to fetch service reviews:', error)
      reviews.value = []
    }
  }

  const bookService = async (id, payload) => {
    try {
      return await serviceApi.bookService(id, payload)
    } catch (error) {
      console.error('Failed to book service:', error)
      throw error
    }
  }

  return {
    services,
    service,
    reviews,
    loading,
    fetchServices,
    fetchServiceById,
    fetchServiceReviews,
    bookService,
  }
})
