import api from './api';
import { ref } from 'vue';
import { authServices } from '../services/auth-services';

export const loading = ref(false);
export const errors = ref({});

// Fungsi login
export const login = async (credentials) => {
  try {
    if (!credentials.email || !credentials.password) {
      errors.value = {
        email: !credentials.email ? ["Email harus diisi."] : undefined,
        password: !credentials.password ? ["Password harus diisi."] : undefined,
      };
      throw new Error("Validasi login gagal");
    }

    const response = await api.post('/login', credentials);

    if (response.data && response.data.token && response.data.user) {
      authServices.setToken(response.data.token);
      authServices.setUserId(response.data.user.id);
    }

    return response.data;
  } catch (error) {
    console.error("Login error:", error.response?.data || error.message);
    throw error;
  }
};

// Fungsi register (opsional, jika backend kamu menyediakan endpoint)
export const register = async (userData) => {
  try {
    const response = await api.post('/register', userData);
    if (response.data.token && response.data.user) {
      authServices.setToken(response.data.token);
      authServices.setUserId(response.data.user.id);
    }
    return response.data;
  } catch (error) {
    console.error("Register error:", error.response?.data || error.message);
    throw error;
  }
};

// Fungsi logout
export const logout = async () => {
  try {
    await api.post('/logout');
    authServices.removeToken();
    authServices.removeUserId();
  } catch (error) {
    console.error("Logout error:", error.response?.data || error.message);
    throw error;
  }
};
