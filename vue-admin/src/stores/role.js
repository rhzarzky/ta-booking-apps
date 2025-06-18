import { defineStore } from "pinia";
import { ref } from "vue";

import {
    createRole,
    permissionApi,
    roleApi,
    deleteRole,
    editRole,
    assignRoleUserApi,
    assignPermissionUserApi,
    assignPermissionRoleApi,
} from "@/api/role-api";

export const useRoleStore = defineStore("roleStore", () => {
    const currentPermission = ref(null);
    const errors = ref({});
    const loading = ref(false);
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
    

    // handle GET Role
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
    };

    // handle delete role
    const handleDeleteRole = async (roleId) => {
        try {
            const response = await deleteRole(roleId);
            if (response.data && response.data.success) {
                showNotification("Role deleted successfully");
                return response.data;
            }
        } catch (error) {
            console.error("Delete role failed:", error);
            if (error.response && error.response.status === 422) {
                errors.value = error.response.data.errors;
            } else {
                errors.value = { general: "Delete role failed. Please try again" };
            }
            throw error;
        }
    };

    // handle edit role
    const handleEditRole = async (roleId, roleData) => {
        try {
            const response = await editRole(roleId, roleData);
            if (response.data && response.data.role) {
                return response.data;
            }
        } catch (error) {
            console.error("Edit role failed:", error);
            if (error.response && error.response.status === 422) {
                errors.value = error.response.data.errors;
            } else {
                errors.value = { general: "Edit role failed. Please try again" };
            }
            throw error;
        }
    };

    // handle GET Permissions
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

    // handle assign permission to role
    const assignPermissionToRole = async (roleId, permissions) => {
        try {
            const response = await assignPermissionRoleApi(roleId, permissions);
            showNotification("Permissions assigned successfully");
            return response.data;
        } catch (error) {
            console.error("Assign permission to role failed:", error);
            if (error.response && error.response.status === 422) {
                errors.value = error.response.data.errors;
            } else {
                errors.value = { general: "Assign permission to role failed. Please try again" };
            }
            throw error;
        }
    };

    // assign permission to user
    const assignPermissionToUser = async (userId, permissions) => {
        try {
            const response = await assignPermissionUserApi(userId, permissions);
            showNotification("Permissions assigned to user successfully");
            return response.data;
        } catch (error) {
            console.error("Assign permission to user failed:", error);
            if (error.response && error.response.status === 422) {
                errors.value = error.response.data.errors;
            } else {
                errors.value = { general: "Assign permission to user failed. Please try again" };
            }
            throw error;
        }
    };

    // assign permission to user
    const assignRoleToUser = async (userId, roles) => {
        try {
            const response = await assignRoleUserApi(userId, roles);
            showNotification("Roles assigned to user successfully");
            return response.data;
        } catch (error) {
            console.error("Assign role to user failed:", error);
            if (error.response && error.response.status === 422) {
                errors.value = error.response.data.errors;
            } else {
                errors.value = { general: "Assign role to user failed. Please try again" };
            }
            throw error;
        }
    };
    
    return {
        errors,
        loading,
        notification,
        userRoles,
        userPermissions,
        currentPermission,
        showNotification,
        fetchRoleApi,
        fetchPermissionApi,
        handleCreateRole,
        handleDeleteRole,
        handleEditRole,
        assignPermissionToRole,
        assignPermissionToUser,
        assignRoleToUser,
      };
});