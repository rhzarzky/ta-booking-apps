import api from "./api";

// GET /booking
export const getBookingApi = () => api.get("/booking");

// GET /booking/:id
export const getBookingDetailApi = (id) => api.get(`/booking/${id}`);

// GET /booking/assigned
export const getAssignedBookingApi = () => api.get("/booking/assigned");

// POST /booking/:id/confirm with payload
export const confirmBookingApi = (id, FormData) => api.post(`/booking/${id}/confirm`, FormData, {
    headers: {
        "Content-Type": "multipart/form-data",
    },
});