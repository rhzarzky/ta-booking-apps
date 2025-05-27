// src/api/auth-api.js
import api from './api';
import { ref } from 'vue';
import { authServices } from '@/services/auth-services';


export const loading = ref(false);
export const errors = ref({});

// Fungsi Login
export const login = async (credentials) => {
  loading.value = true;
  errors.value = {};
  try {
    const response = await api.post('/login', credentials);
    if (response.data?.token && response.data?.user) {
      authServices.setToken(response.data.token);
      authServices.setUserId(response.data.user.id);
    }
    return response.data;
  } catch (error) {
    if (error.response?.status === 422) {
      errors.value = error.response.data.errors;
    } else {
      errors.value = { general: "Login failed. Please try again." };
    }
    throw error;
  } finally {
    loading.value = false;
  }
};

// Fungsi Register
export const register = async (userData) => {
  loading.value = true;
  errors.value = {};
  try {
    const response = await api.post('/register', userData);
    if (response.data?.token && response.data?.user) {
      authServices.setToken(response.data.token);
      authServices.setUserId(response.data.user.id);
    }
    return response.data;
  } catch (error) {
    if (error.response?.status === 422) {
      errors.value = error.response.data.errors;
    } else {
      errors.value = { general: "Registration failed. Please try again." };
    }
    throw error;
  } finally {
    loading.value = false;
  }
};

// Fungsi Logout
export const logout = async () => {
  try {
    await api.post('/logout');
  } catch (error) {
    console.error("Logout error:", error.response?.data || error.message);
  } finally {
    authServices.clearAuthData();
  }
};

// Fungsi Fetch Profile
export const fetchProfile = async () => {
  try {
    const token = authServices.getToken();
    if (!token) throw new Error("Token tidak ditemukan.");
    const response = await api.get('/user/profile');
    return response.data;
  } catch (error) {
    console.error("Fetch profile error:", error.response?.data || error.message);
    throw error;
  }
};

// Fungsi Update Profile
export const updateProfile = async (formData) => {
  try {
    const response = await api.post('/user/profile', formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
    return response.data;
  } catch (error) {
    console.error("Update profile error:", error.response?.data || error.message);
    throw error;
  }
};

// Kirim OTP ke email
export const sendOtp = async (email) => {
  loading.value = true;
  errors.value = {};
  try {
    const response = await api.post('/forgot-password', { email });
    return response.data;
  } catch (error) {
    errors.value = { general: error.response?.data.message || 'Failed to send OTP' };
    throw error;
  } finally {
    loading.value = false;
  }
};

// Verifikasi OTP
export const verifyOtp = async (otp) => {
  loading.value = true;
  errors.value = {};
  try {
    const response = await api.post('/verify-otp', { otp });
    return response.data;
  } catch (error) {
    errors.value = { general: error.response?.data.message || 'OTP verification failed' };
    throw error;
  } finally {
    loading.value = false;
  }
};

// Reset Password setelah OTP diverifikasi
export const resetPassword = async (passwordData) => {
  loading.value = true;
  errors.value = {};
  try {
    const response = await api.post('/reset-password', passwordData);
    return response.data;
  } catch (error) {
    if (error.response?.status === 422) {
      errors.value = error.response.data.errors;
    } else {
      errors.value = { general: error.response?.data.message || 'Reset password failed' };
    }
    throw error;
  } finally {
    loading.value = false;
  }
};

// Kirim ulang OTP
export const resendOtp = async (email) => {
  loading.value = true;
  errors.value = {};
  try {
    const response = await api.post('/resend-otp', { email });
    return response.data;
  } catch (error) {
    errors.value = { general: error.response?.data.message || 'Failed to resend OTP' };
    throw error;
  } finally {
    loading.value = false;
  }
};
