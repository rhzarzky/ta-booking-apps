import api from "./api";
import { ref } from "vue";
import { authServices } from "../services/auth-services";

export const loading = ref(false);
export const errors = ref({});

// ✅ Login API
export const login = async (credentials) => {
  loading.value = true;
  errors.value = {};

  try {
    // Validasi input kosong (optional, bisa dilepas jika sudah divalidasi di frontend)
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
      errors.value = {
        credentials: [error || "Login failed."],
      };
      throw new Error(error || "Login failed.");
    }
  } catch (err) {
    if (err.response?.data?.errors) {
      errors.value = err.response.data.errors;
    }
    console.error("Login error:", err);
    throw err;
  } finally {
    loading.value = false;
  }
};

// ✅ Register API
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
      errors.value = validationErrors || {
        general: ["Registration failed."],
      };
      throw new Error("Register failed");
    }
  } catch (err) {
    if (err.response?.data?.errors) {
      errors.value = err.response.data.errors;
    }
    console.error("Register error:", err);
    throw err;
  } finally {
    loading.value = false;
  }
};

// ✅ Logout API
export const registerUser = async (userData) => {
  try {
    const response = await api.post('/register', userData)

    const { status, token, user } = response.data

    if (status === 'success' && token) {
      authServices.setToken(token)
      authServices.setUser(user)
      return user
    } else {
      throw new Error('Registration failed.')
    }
  } catch (error) {
    const response = error.response
    const status = response?.status
    const errors = response?.data?.errors || {}

    // Khusus jika 401 tapi isinya validasi error, kita anggap ini bukan Unauthorized
    if (status === 401 && Object.keys(errors).length > 0) {
      console.warn('Validation error on registration:', errors)
      throw { validationErrors: errors }
    }

    console.error('Register error:', error)
    throw error
  }
}
// ✅ Get Current User Profile
export const userProfile = async () => {
  try {
    const response = await api.get("/user");
    return response.data;
  } catch (err) {
    console.error("Failed to fetch user profile:", err);
    throw err;
  }
};

// ✅ Export untuk script setup
export { register as RegisterUser, login as LoginUser };
