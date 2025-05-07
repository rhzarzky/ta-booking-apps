import api from "./api";

// List all services
export const getServiceApi = () => {
  return api.get("/service");
};

// Get service detail by ID
export const getServiceDetailApi = (id) => {
  return api.get(`/service/${id}`);
};

// Create a new service (requires data)
export const createServiceApi = (data) => {
  return api.post("/service", data);
};

// Edit an existing service by ID (requires data)
export const editServiceApi = (id, data) => {
  return api.put(`/service/${id}`, data);
};
