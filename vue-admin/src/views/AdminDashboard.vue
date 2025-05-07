<template>
    <div>
        <h1>Service Management</h1>
        <div v-if="servicesStore.isLoading">Loading...</div>
        <div v-if="servicesStore.error" class="error">{{ servicesStore.error }}</div>

        <div v-for="service in servicesStore.services" :key="service.id" class="service-item">
            <img :src="service.image" alt="Service Image" class="service-image" />
            <h3>{{ service.title }}</h3>
            <p>{{ service.description }}</p>
            <p><strong>Location:</strong> {{ service.location }}</p>
            <p><strong>Option:</strong> {{ service.option }}</p>
            <p><strong>Time:</strong> {{ service.time }}</p>
            <p><strong>Available Days:</strong> {{ service.days }}</p>
            <p><strong>Date:</strong> {{ service.date }} - {{ service.end_date }}</p>
        </div>

        <div v-if="servicesStore.notification.show" :class="`notification ${servicesStore.notification.type}`">
            {{ servicesStore.notification.message }}
        </div>
    </div>
</template>

<script>
import { useServicesStore } from "@/stores/service";
import { onMounted } from "vue";

export default {
    name: "AdminDashboard",
    setup() {
        const servicesStore = useServicesStore();

        // Fetch the services when the component is mounted
        onMounted(() => {
            servicesStore.fetchServices();
        });

        return {
            servicesStore,
        };
    },
};
</script>

<style scoped>
.error {
    color: red;
}

.service-item {
    border: 1px solid #ccc;
    padding: 16px;
    margin-bottom: 16px;
}

.service-image {
    max-width: 100px;
    height: auto;
}

.notification {
    margin-top: 20px;
    padding: 10px;
    border-radius: 5px;
    text-align: center;
}

.notification.success {
    background-color: green;
    color: white;
}

.notification.error {
    background-color: red;
    color: white;
}
</style>
