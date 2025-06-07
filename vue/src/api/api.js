import axios from "axios";
import { authServices } from "../services/auth-services";

const api = axios.create({
  baseURL: `${import.meta.env.VITE_BASE_URL}${import.meta.env.VITE_API_PATH}`, 
  timeout: 27000, 
  headers: {
    "Content-Type": "application/json", 
    "x-api-key": authServices.getApiKey?.() || "", 
  },
  withCredentials: false, 
});

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

api.interceptors.response.use(
  (response) => response,
  async (error) => {
    if (error.response?.status === 401) {
      authServices.removeToken();
      // Optional: Redirect ke halaman login
      // window.location.href = "/login"; 
    }
    return Promise.reject(error);
  }
);

export default api;
