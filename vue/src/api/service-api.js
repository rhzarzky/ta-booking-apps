import api from './api';

export const serviceApi = {
  // Ambil semua layanan
  async fetchServices() {
    try {
      const response = await api.get('/service');
      return response.data.services;
    } catch (error) {
      console.error('Gagal mengambil data layanan:', error);
      throw error;
    }
  },

  // Ambil detail layanan berdasarkan ID
  async getServiceById(id) {
    try {
      const response = await api.get(`/service/${id}`);
      return response.data.service;
    } catch (error) {
      console.error(`Gagal mengambil detail layanan dengan ID ${id}:`, error);
      throw error;
    }
  },
    // Booking layanan berdasarkan ID service
    async bookService(serviceId, payload) {
      try {
        const response = await api.post(`/service/${serviceId}/book`, payload);
        return response.data;
      } catch (error) {
        console.error(`Gagal melakukan booking untuk service ID ${serviceId}:`, error);
        throw error;
      }
    }
};

