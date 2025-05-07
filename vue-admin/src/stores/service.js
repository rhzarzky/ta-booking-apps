import { ref } from "vue";
import { defineStore } from "pinia";
import { getServiceApi } from "@/api/service-api"; 

export const useServicesStore = defineStore("useServicesStore", () => {
  const services = ref([]);
  const isLoading = ref(false);
  const error = ref(null);
  
  // Notification state
  const notification = ref({
    show: false,
    message: "",
    type: "success",
  });

  // Function to show notification
  const showNotification = (message, type = "success") => {
    notification.value = {
      show: true,
      message,
      type,
    };
    setTimeout(() => {
      notification.value.show = false;
    }, 3000);
  };
  
  // Function to fetch services
  const fetchServices = async () => {
    isLoading.value = true;
    try {
      const response = await getServiceApi(); 
      if (Array.isArray(response.data)) {
        services.value = response.data.map(service => ({
          id: service.id,
          image: service.image,
          title: service.title,
          description: service.description,
          location: service.location,
          option: service.option,
          time: service.time,
          days: service.days,
          date: service.date,
          end_date: service.end_date,
        }));
      } else {
        services.value = [];
        console.warn("Unexpected response:", response);
      }
    } catch (err) {
      console.error("Fetch failed:", err);
      error.value = err.message || "Failed to fetch services.";
      showNotification("Failed to load services", "error");
    } finally {
      isLoading.value = false;
    }
  };

  return {
    services,
    isLoading,
    error,
    notification,
    showNotification,
    fetchServices,
  };
});
