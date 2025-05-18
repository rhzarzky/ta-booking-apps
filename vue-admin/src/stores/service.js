import { defineStore } from 'pinia'
import {
  getServiceApi,
  createServiceApi,
  editServiceApi,
  deleteServiceApi,
} from "@/api/service-api"; // Importing the API functions

export const useServicesStore = defineStore('services', {
  state: () => ({
    services: [],
    isLoading: false,
    error: null,
    notification: {
      show: false,
      message: '',
      type: 'success',
    },
  }),

  actions: {
    // Fetching services from the API
    async fetchServices() {
      this.isLoading = true;
      this.error = null;
      try {
        const response = await getServiceApi();  // Calling the getServiceApi function

        if (response.data.status === 'success') {
          this.services = response.data.services;
        } else {
          throw new Error(response.data.message || 'Failed to fetch services');
        }
      } catch (err) {
        this.error = err.message || 'An unexpected error occurred';
        this.showNotification(this.error, 'error');
      } finally {
        this.isLoading = false;
      }
    },

    // Create a new service
    async createService(FormData) {
      this.isLoading = true;
      this.error = null;
      try {
        const response = await createServiceApi(FormData);

        if (response.data.status === 'success') {
          this.services.push(response.data.service);  // Add the new service
          this.showNotification('Service created successfully!', 'success');
          return { success: true };
        } else {
          throw new Error(response.data.message || 'Failed to create service');
        }
      } catch (err) {
        this.error = err.response?.data?.errors || err.message || 'An unexpected error occurred';
        this.showNotification(this.error, 'error');
        return { success: false, validationErrors: err.response?.data?.errors };
      } finally {
        this.isLoading = false;
      }
    },

    // Delete a service
    async deleteService(id) {
      this.isLoading = true;
      this.error = null;
      try {
        const response = await deleteServiceApi(id);  // Calling the deleteServiceApi function

        if (response.data.status !== 'success') {
          throw new Error(response.data.message || 'Failed to delete service');
        }
        this.services = this.services.filter(service => service.id !== id);  // Remove the deleted service
        this.showNotification('Service deleted successfully!', 'success');
      } catch (err) {
        this.error = err.message || 'An unexpected error occurred';
        this.showNotification(this.error, 'error');
      } finally {
        this.isLoading = false;
      }
    },

    // Edit an existing service
    async editService(id, updatedData) {
      this.isLoading = true;
      this.error = null;
      try {
        const response = await editServiceApi(id, updatedData);  // Calling the editServiceApi function

        if (response.data.status === 'success') {
          // Update the service in the state
          const index = this.services.findIndex(service => service.id === id);
          if (index !== -1) {
            this.services[index] = response.data.service;
          }
          this.showNotification('Service updated successfully!', 'success');
        } else {
          throw new Error(response.data.message || 'Failed to update service');
        }
      } catch (err) {
        this.error = err.message || 'An unexpected error occurred';
        this.showNotification(this.error, 'error');
      } finally {
        this.isLoading = false;
      }
    },

    // Display notifications
    showNotification(message, type = 'success') {
      this.notification.message = message;
      this.notification.type = type;
      this.notification.show = true;

      // Auto close the notification after 3 seconds
      setTimeout(() => {
        this.notification.show = false;
      }, 3000);
    },
  },
});
