// stores/auth.js
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import axios from 'axios'
import { authServices } from '@/services/auth-services'
import {
  fetchProfile,
  sendOtp,
  verifyOtp,
  resetPassword,
  resendOtp
} from '@/api/auth-api'

export const useAuthStore = defineStore('auth', () => {
  // State
  const user = ref(null)
  const errors = ref({})
  const loading = ref(false)

  // Getters
  const isLoggedIn = computed(() => authServices.isAuthenticated())
  const userName = computed(() => user.value?.name || '')
  const userRole = computed(() => user.value?.role || '')
  const userId = computed(() => user.value?.id || null) // Digunakan di fitur lain seperti review

  // Actions
  const handleLogin = async (credentials) => {
    loading.value = true
    try {
      errors.value = {}
      const response = await axios.post(`${import.meta.env.VITE_API_URL}/login`, credentials)

      if (response.data.status === 'success') {
        user.value = response.data.user
        authServices.setToken(response.data.token)
        authServices.setUserId(response.data.user.id)
      } else {
        errors.value = { general: response.data.message || 'Login failed' }
      }

      return response.data
    } catch (error) {
      if (error.response?.status === 422) {
        errors.value = error.response.data.errors
      } else {
        errors.value = { general: 'Login failed. Please try again.' }
      }
      throw error
    } finally {
      loading.value = false
    }
  }

  const handleRegister = async (userData) => {
    loading.value = true
    try {
      errors.value = {}
      const response = await axios.post(`${import.meta.env.VITE_API_URL}/register`, userData)

      if (response.data.status === 'success') {
        user.value = response.data.user
        authServices.setToken(response.data.token)
        authServices.setUserId(response.data.user.id)
      } else {
        errors.value = { general: response.data.message || 'Registration failed' }
      }

      return response.data
    } catch (error) {
      if (error.response?.status === 422) {
        errors.value = error.response.data.errors
      } else {
        errors.value = { general: 'Registration failed. Please try again.' }
      }
      throw error
    } finally {
      loading.value = false
    }
  }

  const handleLogout = () => {
    user.value = null
    authServices.clearAuthData()
  }

  const getCurrentUser = async () => {
    try {
      const data = await fetchProfile()
      user.value = data.user
      return data
    } catch (error) {
      throw error
    }
  }

  const updateProfile = async (formData) => {
    try {
      const token = authServices.getToken()
      const url = `${import.meta.env.VITE_BASE_URL}${import.meta.env.VITE_API_PATH}/user/profile`

      const response = await axios.post(url, formData, {
        headers: {
          Authorization: `Bearer ${token}`,
          'Content-Type': 'multipart/form-data',
        },
      })

      if (response.data?.user) {
        user.value = response.data.user
      }

      return response.data
    } catch (error) {
      console.error('Error updating profile:', error)
      throw error
    }
  }

  // OTP & Password Reset
  const handleSendOtp = async (email) => {
    loading.value = true
    try {
      errors.value = {}
      const response = await sendOtp(email)
      return response
    } catch (error) {
      throw error
    } finally {
      loading.value = false
    }
  }

  const handleVerifyOtp = async (otp) => {
    loading.value = true
    try {
      errors.value = {}
      const response = await verifyOtp(otp)
      return response
    } catch (error) {
      throw error
    } finally {
      loading.value = false
    }
  }

  const handleResetPassword = async (data) => {
    loading.value = true
    try {
      errors.value = {}
      await resetPassword(data)
    } catch (error) {
      throw error
    } finally {
      loading.value = false
    }
  }

  const handleResendOtp = async (email) => {
    loading.value = true
    try {
      errors.value = {}
      const response = await resendOtp(email)
      return response
    } catch (error) {
      throw error
    } finally {
      loading.value = false
    }
  }

  return {
    user,
    errors,
    loading,
    isLoggedIn,
    userName,
    userRole,
    userId, // ← penting untuk fitur-fitur yang butuh ID user
    handleLogin,
    handleRegister,
    handleLogout,
    getCurrentUser,
    updateProfile,
    handleSendOtp,
    handleVerifyOtp,
    handleResetPassword,
    handleResendOtp,
  }
})
