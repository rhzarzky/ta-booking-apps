import { defineStore } from 'pinia';
import {
  getServiceApi,
  getServiceDetailApi,  
  getAssignedServiceApi,
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

    // Fetching service details by ID
    async fetchServiceDetail(id) {
      this.isLoading = true;
      this.error = null;
      try {
        const response = await getServiceDetailApi(id);  // Calling the getServiceApi function

        if (response.data.status === 'success') {
          return response.data.service;
        } else {
          throw new Error(response.data.message || 'Failed to fetch service details');
        }
      } catch (err) {
        this.error = err.message || 'An unexpected error occurred';
        this.showNotification(this.error, 'error');
      } finally {
        this.isLoading = false;
      }
    },

    // Fetching assigned services for the current user
    async fetchAssignedService() { 
      this.isLoading = true;
      this.error = null;
        try {
            const response = await getAssignedServiceApi();

            if (response.data.status === 'success') {
                // Filter services that are assigned to the current user
                this.services = Object.values(response.data.services).flat();
            }
            else {
                throw new Error(response.data.message || 'Failed to fetch assigned services');
            }
        } catch (err) {
            console.error('Error fetching assigned services:', err);
            this.error = err.response.data.responseMessage || 'An unexpected error occurred';
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

        if (response.data.status !== 'success') {
          throw new Error(response.data.message || 'Failed to create service');
        }

        this.services.push(response.data.service);
        return { success: true };

      } catch (err) {
        const responseMessage = err?.response?.data?.responseMessage;
        const validationErrors = err?.response?.data?.errors;

        this.error =
          responseMessage ||
          validationErrors ||
          err.message ||
          'An unexpected error occurred';

        if (responseMessage) {
          this.showNotification(responseMessage, 'error');
        } else {
          this.showNotification('Failed to create service.', 'error');
        }

        return {
          success: false,
          validationErrors: validationErrors || null,
          message: responseMessage || null,
        };
      } finally {
        this.isLoading = false;
      }
    },

    // Delete a service
    async deleteService(id) {
      this.isLoading = true;
      this.error = null;
      try {
        const response = await deleteServiceApi(id);
    
        if (response.data.status !== 'success') {
          throw new Error(response.data.message || 'Failed to delete service');
        }
    
        this.services = this.services.filter(service => service.id !== id);
        return true; 
      } catch (err) {
        this.error = err.message || 'An unexpected error occurred';
        throw err; 
      } finally {
        this.isLoading = false;
      }
    },

    // Edit an existing service
    async editService(id, FormData) {
      this.isLoading = true;
      this.error = null;
    
      try {
        const response = await editServiceApi(id, FormData);
    
        if (response.data.status === 'success') {
          const index = this.services.findIndex(service => service.id === id);
          if (index !== -1) {
            this.services[index] = {
              ...this.services[index],
              ...response.data.service,
            };
          }
          this.showNotification('Service updated successfully!', 'success');

          return {
            success: true,
            validationErrors: null,
          };
        } else {
          return {
            success: false,
            validationErrors: response.data.errors || {},
          };
        }
      } catch (err) {
        this.error = err.response.data.responseMessage || 'An unexpected error occurred';
        this.showNotification(this.error, 'error');
        console.error('Edit service failed:', err);
    
        return {
          success: false,
          validationErrors: err.response?.data?.errors || {},
        };
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
