import api from "./api";

// GET /service
export const getServiceApi = () => api.get("/service");

// GET /service/:id
export const getServiceDetailApi = (id) => api.get(`/service/${id}`);

// POST /service with payload
export const createServiceApi = (FormData) => api.post("/service", FormData, {
  headers: {
    "Content-Type": "multipart/form-data",
    },
});

// PUT /service/:id with payload
export const editServiceApi = (id, FormData) => api.post(`/service/${id}`, FormData, {
  headers: {
    "Content-Type": "multipart/form-data",
    },
});

// DELETE /service/:id
export const deleteServiceApi = (id) => api.delete(`/service/${id}`);
