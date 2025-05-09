import api from "./api";

// GET /service
export const getServiceApi = () => api.get("/service");

// GET /service/:id
export const getServiceDetailApi = (id) => api.get(`/service/${id}`);

// POST /service with payload
export const createServiceApi = (data) => api.post("/service", data);

// PUT /service/:id with payload
export const editServiceApi = (id, data) => api.put(`/service/${id}`, data);
