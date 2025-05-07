import axios from "axios";

import { authServices } from "@/services/auth-services";

const api = axios.create({
  baseURL: `${import.meta.env.VITE_BASE_URL}${import.meta.env.VITE_API_PATH}`,
  timeout: 17000,
  headers: {
    "Content-Type": "application/json",
    "x-api-key": authServices.getApiKey(),
  },
  withCredentials: true,
});

// interceptor
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
      //window.location.href = "/";
    }
    return Promise.reject(error);
  }
);
export default api;

