import axios from 'axios'
import { authServices } from '../services/auth-services'

const api = axios.create({
  baseURL: `${import.meta.env.VITE_BASE_URL}${import.meta.env.VITE_API_PATH}`,
  timeout: 15000,
  headers: {
    'Content-Type': 'application/json',
    ...(authServices.getApiKey && authServices.getApiKey() && {
      'x-api-key': authServices.getApiKey()
    })
  },
  withCredentials: false,
})

// Interceptor untuk menambahkan token ke setiap request
api.interceptors.request.use(
  (config) => {
    const token = authServices.getToken()
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  (error) => Promise.reject(error)
)

// Interceptor untuk menangani error dari response
api.interceptors.response.use(
  (response) => response,
  (error) => {
    const originalRequest = error.config
    const status = error.response?.status
    const requestUrl = originalRequest?.url

    console.error('API Error:')
    console.log('Status:', status)
    console.log('Request URL:', requestUrl)
    console.log('Response:', error.response?.data)

    // Hanya logout jika 401 bukan dari login atau register
    if (
      status === 401 &&
      requestUrl &&
      !requestUrl.includes('/login') &&
      !requestUrl.includes('/register')
    ) {
      console.warn('Token expired or invalid. Logging out...')
      authServices.clearAuth()
      // Optional: window.location.href = '/login'
    }

    return Promise.reject(error)
  }
)

export default api
