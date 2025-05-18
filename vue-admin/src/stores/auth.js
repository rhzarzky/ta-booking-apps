import { defineStore } from "pinia";
import { computed, ref } from "vue";

import {
  login,
  logout,
  deleteUserId,
  fetchUsers,
  updateUser,
  getUserById,
  userProfile,
  updateProfile,
  currentUserApi,
  permissionApi,
} from "@/api/auth-api";
import { authServices } from "@/services/auth-services";

export const useAuthStore = defineStore("authStore", () => {
  const errors = ref({});
  const user = ref(null);
  const currentUser = ref(null);
  const currentPermission = ref(null);
  const users = ref(null);
  const loading = ref(false);

  const isLoggedIn = computed(() => authServices.isAuthenticated());

  const notification = ref({
    show: false,
    message: "",
    type: "success",
  });

  const showNotification = (message, type = 'success') => {
    notification.value.message = message;
    notification.value.type = type;
    notification.value.show = true;
  
    setTimeout(() => {
      notification.value.show = false;
    }, 3000); // Hide notification after 3 seconds
  };

  // Permissions
  const userPermissions = ref([]);
  const fetchPermissionApi = async () => {
    try {
        const permissions = await permissionApi();
        console.log("Fetched Permissions:", permissions);
        currentPermission.value = permissions.map(p => p.name); 
    } catch (err) {
        console.error("Failed to fetch permission", err);
    }
};

  // Fetch user with permissions
const fetchUserWithPermissions = async (selectedUserId) => {
  try {
      const response = await getUserById(selectedUserId); // Mengambil user berdasarkan ID
      console.log("API response:", response); // Tambah logisasi ini
      if (response.data && response.data.user) {
          const userData = response.data.user;
          return {
              ...userData,
              permissions: userData.permissions || [],
          };
      }
      throw new Error("User not found");
  } catch (err) {
      console.error("Error fetching user with permissions:", err);
      throw err;
  }
};

  // handle fetch current user api
  const fetchCurrentUserApi = async () => {
    try {
      const response = await currentUserApi();
      currentUser.value = response.data.user;
      currentPermission.value = response.data.user.permissions;
    } catch (err) {
      console.error("failed to fetch current user", err);
    }
  };

  const fetchCurrentUser = async () => {
    try {
      await fetchCurrentUserApi();  // Mengambil info pengguna yang sedang login
    } catch (err) {
      console.error("failed to fetch current user", err);
    }
  };

  // handle all users api
  const fetchUsersApi = async () => {
    try {
      const response = await fetchUsers();
      if (
        response?.data?.status === "success" &&
        Array.isArray(response.data.users)
      ) {
        users.value = response.data.users;
      } else {
        console.warn("Unexpected response format:", response);
        users.value = [];
      }
    } catch (err) {
      if (err.response?.status === 403 || err.response?.status === 401) {
        errors.value = {
          general: [
            "You are not authorized to view the users. Please log in again.",
          ],
        };
      } else {
        errors.value = {
          general: "Failed to fetch users. Please try again.",
        };
      }

      throw err;
    }
  };

  // handle login api
  const handleLogin = async (credentials) => {
    loading.value = true;
    try {
      errors.value = {};
      const response = await login(credentials);
      user.value = response.user;
      authServices.setToken(response.token);
      authServices.setUserId(response.user.id);
      authServices.setRole(response.user.role[0]);
      return response;
    } catch (error) {
      if (error.response && error.response.status === 422) {
        errors.value = error.response.data.errors;
      } else {
        errors.value = {
          general: "Login failed. Please try again",
        };
      }
      throw error;
    } finally {
      loading.value = false;
    }
  };

  // handle get user by id
  const handleGetUserById = async (id) => {
    if (!id) {
      console.error("Get Id user failed: id is null");
      return null;
    }
    try {
      const response = await getUserById(id);
      if (response.data && response.data.user) {
        user.value = response.data.user; // Menyimpan data pengguna dalam store
        return response.data;
      } else {
        throw new Error("User data not found");
      }
    } catch (error) {
      console.error("Get Id user failed:", error);
      throw error;
    }
  };

  // handle logout
  const handleLogout = async () => {
    try {
      await logout();
      user.value = null;
      authServices.removeToken();
      authServices.removeUserId();
      authServices.removeRole();
    } catch (error) {
      console.error("Logout failed:", error);
    }
  };

  // handle delete user
  const handleDeleteUser = async (userId) => {
    try {
      const response = await deleteUserId(userId);
      return response;
    } catch (error) {
      console.error("Delete user failed:", error);
      if (error.response && error.response.status === 422) {
        errors.value = error.response.data.errors;
      } else {
        errors.value = { general: "Delete user failed. Please try again" };
      }
      throw error;
    }
  };

  // handle update user
  const handleUpdateUser = async (userId, userData) => {
    console.log("Update Data to be sent:", userData);
    try {
        const response = await updateUser(userId, userData);
        return response;
    } catch (error) {
        console.error("Update user failed:", error);
        if (error.response) {
            console.error("Response data:", error.response.data); // Tampilkan data kesalahan
        } else {
            errors.value = { general: "Update user failed. Please try again." };
        }
        throw error;
    }
};

  // handle user profile api
  const handleUserProfile = async () => {
    try {
      const response = await userProfile();
      user.value = response.user;
    } catch (error) {
      console.error("Failed to fetch user profile:", error);
      errors.value = { general: "Failed to fetch user profile." };
      throw error;
    }
  };

  // handle update profile api
  const handleUpdateProfile = async (userData) => {
    try {
      const response = await updateProfile(userData);
      user.value = response.user;
      return response;
    } catch (error) {
      console.error("Update profile failed:", error);
      if (error.response && error.response.data.errors) {
        errors.value = error.response.data.errors;
      } else {
        errors.value = {
          general: ["Update profile failed. Please try again."],
        };
      }
      throw error;
    }
  };

  return {
    errors,
    users,
    user,
    isLoggedIn,
    userPermissions,
    loading,
    currentPermission,
    currentUser,
    notification,
    showNotification,
    fetchPermissionApi,
    fetchCurrentUserApi,
    fetchCurrentUser,
    fetchUsersApi,
    fetchUserWithPermissions,
    handleLogin,
    handleLogout,
    handleDeleteUser,
    handleGetUserById,
    handleUpdateUser,
    handleUserProfile,
    handleUpdateProfile,
  };
});
