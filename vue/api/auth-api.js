import api from "./api"
import { authServices } from "../services/auth-services"

// ✅ Login API
export const login = async (credentials) => {
  try {
    const response = await api.post("/login", credentials)
    const { status, token, user, error } = response.data

    if (status === "success" && token) {
      authServices.setToken(token)
      authServices.setUser(user)
      return user
    } else {
      throw new Error(error || "Login failed.")
    }
  } catch (err) {
    throw err
  }
}

// ✅ Register API
export const register = async (userData) => {
  try {
    const response = await api.post("/register", userData);
    if (response.data.token) {
      authServices.setToken(response.data.token);
    }
    return response.data;
  } catch (error) {
    console.error("Register error:", error.response?.data || error.message);
    throw error;
  }
};




export const logout = async () => {
  try {
    // Kalau kamu ingin kasih tahu backend:
    await api.post('/logout') // opsional tergantung backend kamu
  } catch (err) {
    console.warn("Logout error (ignored):", err)
  } finally {
    authServices.clearToken()
    authServices.clearUser()
  }
}

export const userProfile = async () => {
  try {
    const response = await api.get("/user")
    return response.data
  } catch (err) {
    console.error("Failed to fetch user profile:", err)
    throw err
  }
}

// setup 
export { register as RegisterClient, login as LoginClient, logout as LogoutClient }

