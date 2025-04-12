import axios from "axios";
import { authServices } from "@/services/auth-services";

// Membuat instance Axios dengan konfigurasi default
const api = axios.create({
  baseURL: `${import.meta.env.VITE_BASE_URL}${import.meta.env.VITE_API_PATH}`, // contoh: http://localhost:8000/api
  timeout: 17000,
  headers: {
    "Content-Type": "application/json",
    "x-api-key": authServices.getApiKey?.() || "", // opsional, hanya jika kamu pakai api key
  },
  withCredentials: false, 
});

// Interceptor REQUEST: Menambahkan Authorization header jika token tersedia
api.interceptors.request.use(
  (config) => {
    const token = authServices.getToken();
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// Interceptor RESPONSE: Menangani error global seperti 401 (unauthorized)
api.interceptors.response.use(
  (response) => response,
  async (error) => {
    if (error.response?.status === 401) {
      authServices.removeToken();
      // Optional: redirect ke login kalau perlu
      // window.location.href = "/login";
    }
    return Promise.reject(error);
  }
);

export default api;
