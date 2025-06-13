import { defineStore } from 'pinia';
import {
    reverseGeocodeApi,
    searchGeocodeApi
} from "@/api/map-api"; 

export const useMapsStore = defineStore('maps', {
    state: () => ({
        maps: [],
        isLoading: false,
        error: null,
        notification: {
            show: false,
            message: '',
            type: 'success',
        },
    }),


    actions: {
        // Reverse geocode API call
        async reverseGeocode(lng, lat) {
            this.isLoading = true;
            this.error = null;
            try {
                const response = await reverseGeocodeApi(lng, lat);
                if (response.data.features && response.data.features.length > 0) {
                    return response.data.features[0];
                } else {
                    throw new Error('No results found for the given coordinates');
                }
            } catch (err) {
                this.error = err.message || 'An unexpected error occurred';
                this.showNotification(this.error, 'error');
            } finally {
                this.isLoading = false;
            }
        },

        // Search geocode API call
        async searchGeocode(searchQuery) {
            this.isLoading = true;
            this.error = null;
            try {
                const response = await searchGeocodeApi(searchQuery);
                if (response.data.features && response.data.features.length > 0) {
                    return response.data.features;
                } else {
                    throw new Error('No results found for the search query');
                }
            } catch (err) {
                this.error = err.message || 'An unexpected error occurred';
                this.showNotification(this.error, 'error');
            } finally {
                this.isLoading = false;
            }
        },

        // Show notification
        showNotification(message, type = 'success') {
            this.notification.show = true;
            this.notification.message = message;
            this.notification.type = type;

            setTimeout(() => {
                this.notification.show = false;
            }, 3000); // Hide notification after 3 seconds
        },
    },
});