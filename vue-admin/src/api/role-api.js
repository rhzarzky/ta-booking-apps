import api from "./api";
  
// GET role api
export const roleApi = async () => {
    try {
        const response = await api.get("/role");
        console.log("Role API Response:", response.data);
        return response.data;
    } catch (error) {
        console.error("Failed to fetch roles:", error);
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
};

// delete role api
export const deleteRole = async (roleId) => {
    try {
        const response = await api.delete(`/role/${roleId}`);
        return response.data;
    } catch (error) {
        console.error("Delete role error", error.response?.data || error.message);
        throw error;
    }
};

// Edit role api
export const editRole = async (roleId, roleData) => {
    try {
        const response = await api.put(`/role/${roleId}`, roleData);
        return response.data;
    } catch (error) {
        console.error("Edit role error", error.response?.data || error.message);
        throw error;
    }
};

// GET permission api from user
export const permissionApi = async () => {
    try {
      const response = await api.get("/permission");
      console.log("Permission API Response:", response.data); 
      return response.data; 
    } catch (error) {
      console.error("Failed to fetch permissions:", error);
      throw error; 
    }
};

// assign permission to role api
export const assignPermissionRoleApi = async (roleId, permissions) => {
    try {
        const response = await api.post(`/role/${roleId}/assign-permission-role`, { permissions });
        return response.data;
    } catch (error) {
        console.error("Assign permission to role error", error.response?.data || error.message);
        throw error;
    }
};

// assign permission to user api
export const assignPermissionUserApi = async (userId, permissions) => {
    try {
        const response = await api.post(`/users/${userId}/assign-permission`, { permissions });
        return response.data;
    } catch (error) {
        console.error("Assign permission to user error", error.response?.data || error.message);
        throw error;
    }
};

// assign permission to user api
export const assignRoleUserApi = async (userId, roles) => {
    try {
        const response = await api.post(`/users/${userId}/assign-role`, { roles });
        return response.data;
    } catch (error) {
        console.error("Assign role to user error", error.response?.data || error.message);
        throw error;
    }
};


