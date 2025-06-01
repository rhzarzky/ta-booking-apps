import api from "./api";

import { ref } from "vue";

import { authServices } from "@/services/auth-services";

export const loading = ref(false);
export const errors = ref({});

// login api
export const login = async (credentials) => {
  try {
    if (!credentials.email || !credentials.password) {
      errors.value = {
        email: !credentials.email
          ? ["The email field is required."]
          : undefined,
        password: !credentials.password
          ? ["The password field is required."]
          : undefined,
      };
      throw new Error("Validation failed");
    }
    const response = await api.post("/login", credentials);
    if (response.data.token) {
      authServices.setToken(response.data.token);
      authServices.setUserId(response.data.id);
    }
    return response.data;
  } catch (error) {
    console.error("Login error:", error.response?.data || error.message);
    throw error;
  }
};

// create user api
export const createUser = async (userData) => {
  try {
    const response = await api.post("/users", userData);
    return response.data;
  } catch (error) {
    console.error("Create user error", error.response?.data || error.message);
    throw error;
  }
};

// create role api
export const createRole = async (roleData) => {
  try {
    const response = await api.post("/role", roleData);
    return response.data;
  } catch (error) {
    console.error("Create role error", error.response?.data || error.message);
    throw error;
  }
}

// logout api
export const logout = async () => {
  try {
    await api.post("/logout");
    authServices.removeToken();
  } catch (error) {
    console.error("Logout error:", error.response?.data || error.message);
    throw error;
  }
};

// all user api
export const fetchUsers = async () => {
  try {
    const response = await api.get("/users");
    return response.data;
  } catch (error) {
    console.error("Failed to fetch user data", error);
    if (error.response) {
      console.error("Response data:", error.response.data);
      throw error;
    }
  }
};

// user by id api
export const getUserById = async (id) => api.get(`/users/${id}`);

// delete user api
export const deleteUserId = async (id) => {
  try {
    const response = await api.delete(`/users/${id}`);
    return response.data; 
  } catch (error) {
    console.error("Delete user error:", error.response?.data || error.message);
    throw error; 
  }
};

// update user api by id
export const updateUser = async (id, userData) => {
  try {
    const response = await api.put(`/users/${id}`, userData);
    return response.data;
  } catch (error) {
    console.error("Update user error:", error.response?.data || error.message);
    throw error;
  }
};

// user profile api
export const userProfile = async () => {
  try {
    const response = await api.get("/user/profile");
    return response.data; 
  } catch (error) {
    console.error("Failed to fetch user profile:", error);
    throw error; 
  }
};

// update profile api
export const updateProfile = async (userData) => {
  try {
    const response = await api.put("/user/profile", userData);
    return response.data; 
  } catch (error) {
    console.error("Update profile error:", error);
    throw error; 
  }
};

// current user api
export const currentUserApi = () => api.get("/user/profile");

// permission api
export const permissionApi = async () => {
  try {
    const response = await api.get("/permission");
    console.log("Permission API Response:", response.data); 
    return response.data; // Ubah dari return response; menjadi return response.data untuk memastikan data yang benar
  } catch (error) {
    console.error("Failed to fetch permissions:", error);
    throw error; 
  }
};

//  role api
export const roleApi = async () => {
  try {
    const response = await api.get("/role");
    console.log("Role API Response:", response.data); 
    return response.data; // Ubah dari return response; menjadi return response.data untuk memastikan data yang benar
  } catch (error) {
    console.error("Failed to fetch roles:", error);
    throw error; 
  }
}