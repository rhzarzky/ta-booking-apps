// stores/service.js
import { defineStore } from 'pinia'
import { ref } from 'vue'
import { serviceApi } from '@/api/service-api'

export const useServiceStore = defineStore('service', () => {
  const services = ref([])
  const service = ref(null)
  const loading = ref(false)

  const serviceReviews = ref([]) // ✅ Tambahkan ini
  const averageRating = ref(0)
  const totalReviews = ref(0)
  const loadingReviews = ref(false)
  const reviewError = ref(null)

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
      console.error(`Failed to fetch service by id:`, error)
    } finally {
      loading.value = false
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

  const fetchServiceReviews = async (serviceId) => {
    loadingReviews.value = true
    reviewError.value = null
    try {
      const data = await serviceApi.getServiceReviews(serviceId)
      serviceReviews.value = data.reviews || []
      averageRating.value = data.average_rating || 0
      totalReviews.value = data.total_reviews || 0
    } catch (error) {
      console.error(`Failed to fetch reviews for service (id: ${serviceId}):`, error)
      reviewError.value = 'Gagal memuat ulasan layanan.'
      serviceReviews.value = []
      averageRating.value = 0
      totalReviews.value = 0
    } finally {
      loadingReviews.value = false
    }
  }

  return {
    services,
    service,
    loading,
    fetchServices,
    fetchServiceById,
    bookService,

    serviceReviews,
    loadingReviews,
    reviewError,
    averageRating,
    totalReviews,
    fetchServiceReviews
  }
})
