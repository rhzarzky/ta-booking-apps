import { defineStore } from "pinia";
import { computed, ref } from "vue";

import {
  login,
  createUser,
  createRole,
  logout,
  deleteUserId,
  fetchUsers,
  updateUser,
  getUserById,
  userProfile,
  updateProfile,
  currentUserApi,
  permissionApi,
  roleApi,
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

  // Notification
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
  
  // Role
  const userRoles = ref([]);
  const fetchRoleApi = async () => {
    try {
      const roles = await roleApi();
      console.log("Fetched Roles:", roles);
      return roles; //return the array
    } catch (err) {
      console.error("Failed to fetch roles", err);
      return []; 
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

  // Check if user has a specific permission
  const hasPermission = (permissionName) => {
    return currentUser.value?.permissions?.includes(permissionName);
  };

  // Fetch current user
  const fetchCurrentUser = async () => {
    try {
      await fetchCurrentUserApi();
    } catch (err) {
      console.error("failed to fetch current user", err);
    }
  };

  // Fetch all users
  const fetchUsersApi = async () => {
    try {
      const response = await fetchUsers(); 
      console.log("fetchUsers response:", response); // Debug log
  
      if (
        response?.status === "success" &&
        Array.isArray(response.users)
      ) {
        const userList = response.users;
        users.value = userList;
  
        return {
          success: true,
          users: userList,
        };
      } else {
        console.warn("Unexpected response format:", response);
        users.value = [];
  
        return {
          success: false,
          users: [],
        };
      }
    } catch (err) {
      console.error("fetchUsers error:", err);
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
  
      return {
        success: false,
        users: [],
      };
    }
  };

  // handle login api
  const handleLogin = async (credentials) => {
    loading.value = true;
    try {
      errors.value = {};
      const response = await login(credentials);

      const userRole = response.user.role[0];
      
      if (userRole === "user") {
        errors.value = {
          general: "Users are not allowed to log in to the admin panel. Please contact the administrator.",
        };
        await logout();
        throw new Error("Unauthorized role");
      }

      user.value = response.user;
      authServices.setToken(response.token);
      authServices.setUserId(response.user.id);
      authServices.setRole(userRole);

      return response;
    } catch (error) {
      if (error.response && error.response.status === 422) {
        errors.value = error.response.data.errors;
      } else if (!errors.value.general) {
        errors.value = {
          general: "Login failed. Please check your credentials and try again.",
        };
      }
      throw error;
    } finally {
      loading.value = false;
    }
  };

  // handle create user
  const handleCreateUser = async (userData) => {
    try {
      const response = await createUser(userData);
      if (response.data && response.data.user) {
        users.value.push(response.data.user); // Menambahkan pengguna baru ke dalam store
        return response.data;
      }
    } catch (error) {
      console.error("Create user failed:", error);
      if (error.response && error.response.status === 422) {
        errors.value = error.response.data.errors;
      } else {
        errors.value = { general: "Create user failed. Please try again" };
      }
      throw error;
    }
  };

  // handle create role
  const handleCreateRole = async (roleData) => {
    try {
      const response = await createRole(roleData);
      if (response.data && response.data.role) {
        return response.data;
      }
    } catch (error) {
      console.error("Create role failed:", error);
      if (error.response && error.response.status === 422) {
        errors.value = error.response.data.errors;
      } else {
        errors.value = { general: "Create role failed. Please try again" };
      }
      throw error;
    }
  }

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
    userRoles,
    loading,
    currentPermission,
    currentUser,
    notification,
    showNotification,
    fetchRoleApi,
    fetchPermissionApi,
    fetchCurrentUserApi,
    fetchCurrentUser,
    fetchUsersApi,
    fetchUserWithPermissions,
    hasPermission,
    handleLogin,
    handleLogout,
    handleDeleteUser,
    handleCreateUser,
    handleCreateRole,
    handleGetUserById,
    handleUpdateUser,
    handleUserProfile,
    handleUpdateProfile,
  };
});
