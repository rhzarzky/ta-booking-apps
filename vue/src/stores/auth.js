import { defineStore } from 'pinia'
import { ref } from 'vue'
import { login, logout, register, userProfile} from '../../api/auth-api'
import { authServices } from '../../services/auth-services'


export const useAuthStore = defineStore('auth', () => {
  const user = ref(authServices.getUser())
  const isAuthenticated = ref(authServices.isLoggedIn())

  const loginUser = async (credentials) => {
    const res = await login(credentials)
    user.value = res.user
    isAuthenticated.value = true
  }

  const registerUser = async (userData) => {
    const res = await register(userData)
    user.value = res.user
    isAuthenticated.value = true
  }

  const logoutUser = async () => {
    await logout()
    user.value = null
    isAuthenticated.value = false
  }

  const fetchUserProfile = async () => {
    const data = await userProfile()
    user.value = data
  }

  return {
    user,
    isAuthenticated,
    loginUser,
    registerUser,
    logoutUser,
    fetchUserProfile,
  }
})
