import axios from 'axios'
import { useAuthStore } from '@/stores/auth'

const api = axios.create({
  baseURL: 'http://127.0.0.1:8000/v1',
})

api.interceptors.request.use((config) => {
  // Panggil store DI DALAM interceptor
  const authStore = useAuthStore()
  const token = authStore?.token

  // Jangan tambahkan token untuk login & register
  if (token && !['/login', '/register'].includes(config.url)) {
    config.headers.Authorization = `Bearer ${token}`
    console.log('[Request Interceptor] Token DITAMBAHKAN:', config.url)
  } else {
    console.log('[Request Interceptor] Token TIDAK ditambahkan:', config.url)
  }

  return config
}, error => Promise.reject(error))

export default api
