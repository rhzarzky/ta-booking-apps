import api from "./api";
import { ref } from "vue";
import { authServices } from "@/services/auth-services";

export const loading = ref(false);
export const errors = ref({});

// login api
export const login = async (credentials) => {
  loading.value = true;
  errors.value = {};
  try {
    if (!credentials.email || !credentials.password) {
      errors.value = {
        email: !credentials.email ? ["The email field is required."] : undefined,
        password: !credentials.password ? ["The password field is required."] : undefined,
      };
      throw new Error("Validation failed");
    }

    const response = await api.post("/login", credentials);
    const { status, token, user, error } = response.data;

    if (status === "success" && token) {
      authServices.setToken(token);
      authServices.setUser(user);
      return user;
    } else {
      errors.value = { credentials: [error || "Login failed."] };
      throw new Error(error || "Login failed");
    }
  } catch (error) {
    console.error("Login error:", error);
    throw error;
  } finally {
    loading.value = false;
  }
};

// register api
export const register = async (userData) => {
  loading.value = true;
  errors.value = {};
  try {
    const response = await api.post("/register", userData);
    const { status, token, user, errors: validationErrors } = response.data;

    if (status === "success" && token) {
      authServices.setToken(token);
      authServices.setUser(user);
      return user;
    } else {
      errors.value = validationErrors || { general: ["Registration failed."] };
      throw new Error("Register failed");
    }
  } catch (error) {
    console.error("Register error:", error);
    throw error;
  } finally {
    loading.value = false;
  }
};

// logout api
export const logout = async () => {
  try {
    const response = await api.post("/logout");
    if (response.data.status === "success") {
      authServices.clearAuth();
    }
  } catch (error) {
    console.error("Logout error:", error.response?.data || error.message);
    throw error;
  }
};

// get current user
export const userProfile = async () => {
  try {
    const response = await api.get("/user");
    return response.data;
  } catch (error) {
    console.error("Failed to fetch user profile:", error);
    throw error;
  }
};
