import { defineStore } from 'pinia';
import {
  getBookingApi,
  getBookingDetailApi,
  confirmBookingApi,
} from "@/api/booking-api"; 

export const useBookingStore = defineStore('booking', {
    state: () => ({
        bookings: [],
        isLoading: false,
        error: null,
        notification: {
            show: false,
            message: '',
            type: 'success',
        },
    }),

    actions: {
        // Fetching bookings from the API
        async fetchBookings() {
            this.isLoading = true;
            this.error = null;
            try {
              const response = await getBookingApi();
          
              if (response.data.status === 'success') {
                // get all bookings and flatten the structure
                this.bookings = Object.values(response.data.bookings).flat();
              } else {
                throw new Error(response.data.message || 'Failed to fetch bookings');
              }
            } catch (err) {
                console.error('Error fetching bookings:', err);
              this.error = err.response.data. responseMessage || 'An unexpected error occurred';
              this.showNotification(this.error, 'error');
            } finally {
              this.isLoading = false;
            }
          },
          
        // Fetching booking details by ID
        async fetchBookingDetail(id) {
            this.isLoading = true;
            this.error = null;
            try {
                const response = await getBookingDetailApi(id); 

                if (response.data.status === 'success') {
                    return response.data.booking;
                } else {
                    throw new Error(response.data.message || 'Failed to fetch booking details');
                }
            } catch (err) {
                this.error = err.message || 'An unexpected error occurred';
                this.showNotification(this.error, 'error');
            } finally {
                this.isLoading = false;
            }
        },

        // Confirming a booking
        async confirmBooking(id, FormData) {
            this.isLoading = true;
            this.error = null;
            try {
                const response = await confirmBookingApi(id, FormData);

                if (response.data.status === 'success') {
                    this.showNotification('Booking status confirmed successfully', 'success');
                    return response.data.booking; 
                } else {
                    throw new Error(response.data.message || 'Failed to confirm booking');
                }
            } catch (err) {
                this.error = err.message || 'An unexpected error occurred';
                this.showNotification(this.error, 'error');
            } finally {
                this.isLoading = false;
            }
        },

        // Show notification
        showNotification(message, type) {
            this.notification.show = true;
            this.notification.message = message;
            this.notification.type = type;

            setTimeout(() => {
                this.notification.show = false;
            }, 3000);
        },
    },
});