import axios from "axios";
import { authServices } from "../services/auth-services";

// Membuat instance Axios dengan konfigurasi default
const api = axios.create({
  baseURL: `${import.meta.env.VITE_BASE_URL}${import.meta.env.VITE_API_PATH}`, // Menggunakan environment variables untuk base URL dan API path
  timeout: 17000, // Waktu timeout request
  headers: {
    "Content-Type": "application/json", // Jenis konten JSON
    "x-api-key": authServices.getApiKey?.() || "", // Opsional: Hanya jika menggunakan API key
  },
  withCredentials: false, // Tidak menggunakan cookie
});

// Interceptor REQUEST: Menambahkan Authorization header jika token tersedia
api.interceptors.request.use(
  (config) => {
    const token = authServices.getToken(); // Mengambil token dari authServices
    if (token) {
      config.headers.Authorization = `Bearer ${token}`; // Menambahkan token ke header Authorization
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// Interceptor RESPONSE: Menangani error global seperti 401 (Unauthorized)
api.interceptors.response.use(
  (response) => response,
  async (error) => {
    if (error.response?.status === 401) {
      authServices.removeToken(); // Hapus token jika 401 Unauthorized
      // Optional: Redirect ke halaman login
      // window.location.href = "/login"; 
    }
    return Promise.reject(error);
  }
);

export default api;
