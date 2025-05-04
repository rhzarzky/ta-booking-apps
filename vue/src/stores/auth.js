import { defineStore } from 'pinia';
import { ref, computed } from 'vue';
import axios from 'axios';
import { authServices } from '../services/auth-services';

export const useAuthStore = defineStore('auth', () => {
  const user = ref(null);
  const errors = ref({});
  const loading = ref(false);

  const isLoggedIn = computed(() => authServices.isAuthenticated());

  // Handle Login
  const handleLogin = async (credentials) => {
    loading.value = true;
    try {
      errors.value = {};
      const response = await axios.post(`${import.meta.env.VITE_API_URL}/login`, credentials);

      if (response.data.status === 'success') {
        user.value = response.data.user;
        authServices.setToken(response.data.token);
        authServices.setUserId(response.data.user.id);
      } else {
        errors.value = { general: response.data.message || 'Login failed' };
      }

      return response.data;
    } catch (error) {
      if (error.response?.status === 422) {
        errors.value = error.response.data.errors;
      } else {
        errors.value = { general: 'Login failed. Please try again.' };
      }
      throw error;
    } finally {
      loading.value = false;
    }
  };

  // ✅ Handle Register
  const handleRegister = async (userData) => {
    loading.value = true;
    try {
      errors.value = {};
      const response = await axios.post(`${import.meta.env.VITE_API_URL}/register`, userData);

      if (response.data.status === 'success') {
        user.value = response.data.user;
        authServices.setToken(response.data.token);
        authServices.setUserId(response.data.user.id);
      } else {
        errors.value = { general: response.data.message || 'Registration failed' };
      }

      return response.data;
    } catch (error) {
      if (error.response?.status === 422) {
        errors.value = error.response.data.errors;
      } else {
        errors.value = { general: 'Registration failed. Please try again.' };
      }
      throw error;
    } finally {
      loading.value = false;
    }
  };

  // Logout
  const handleLogout = () => {
    user.value = null;
    authServices.clearAuthData();
  };

  // Get current user
  const getCurrentUser = async () => {
    try {
      const token = authServices.getToken();
      const response = await axios.get(`${import.meta.env.VITE_API_URL}/profile`, {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      });

      if (response.data.user) {
        user.value = response.data.user;
      }
    } catch (error) {
      console.error('Failed to fetch current user:', error);
      throw error;
    }
  };

  // Update user profile
  const updateProfile = async (formData) => {
    try {
      const token = authServices.getToken();
      const BASE_URL = import.meta.env.VITE_BASE_URL;
      const API_PATH = import.meta.env.VITE_API_PATH;
      const url = `${BASE_URL}${API_PATH}/user/profile`;
  
      const response = await axios.put(url, formData, {
        headers: {
          Authorization: `Bearer ${token}`,
          'Content-Type': 'multipart/form-data',
        },
      });
  
      if (response.data.user) {
        user.value = response.data.user;
      }
  
      return response.data;
    } catch (error) {
      console.error('Error updating profile:', error);
      throw error;
    }
  };
  

  return {
    user,
    errors,
    loading,
    isLoggedIn,
    handleLogin,
    handleRegister,
    handleLogout,
    getCurrentUser,
    updateProfile,
  };
});
