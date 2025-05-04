import { defineStore } from 'pinia'
import { ref } from 'vue'
import { serviceApi } from '@/api/service-api'

export const useServiceStore = defineStore('service', () => {
  const services = ref([])
  const service = ref(null)
  const loading = ref(false)

  const loadServices = async () => {
    loading.value = true
    try {
      services.value = await serviceApi.fetchServices()
    } catch (error) {
      console.error('Failed to load services:', error)
    } finally {
      loading.value = false
    }
  }

  const loadServiceById = async (id) => {
    loading.value = true
    try {
      service.value = await serviceApi.getServiceById(id)
    } catch (error) {
      console.error(`Failed to load service ID ${id}:`, error)
    } finally {
      loading.value = false
    }
  }

  return {
    services,
    service,
    loading,
    loadServices,
    loadServiceById
  }
})
