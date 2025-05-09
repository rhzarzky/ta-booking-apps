<template>
    <DefaultLayout class="bg-whiteBgPrimary-100">
        <!-- Notifikasi -->
        <AlertStatus :message="servicesStore.notification.message" :type="servicesStore.notification.type"
            :is-visible="servicesStore.notification.show" @close="servicesStore.notification.show = false" />

        <div class="rounded-2xl bg-white shadow-lg shadow-wildsand-100">
            <!-- Header Filter dan Search -->
            <div class="p-4 bg-white flex flex-col gap-2 items-center md:flex-row justify-between rounded-t-2xl">
                <!-- Search -->
                <div class="w-full md:w-100">
                    <input v-model="searchQuery" type="text" placeholder="Search by service title"
                        class="w-full px-4 py-2 border md:border-2 border-wildsand-200 rounded-lg text-codgray-900 font-medium cursor-pointer focus:outline-none focus:ring-2 focus:ring-offset-2 focus:text-cobalt-700 focus:ring-cobalt-600 hover:border-cobalt-500 transition-colors duration-200 text-sm md:text-base ease-in-out" />
                </div>

                <!-- Filter Option -->
                <div class="w-full md:w-64">
                    <select v-model="selectedOption"
                        class="w-full px-4 py-2 border md:border-2 border-wildsand-200 rounded-lg text-codgray-900 font-medium cursor-pointer focus:outline-none focus:ring-2 focus:ring-offset-2 focus:text-cobalt-700 focus:ring-cobalt-600 hover:border-cobalt-500 transition-colors duration-200 ease-in-out text-sm md:text-base">
                        <option value="all">All Options</option>
                        <option value="Offline">Offline</option>
                        <option value="Online">Online</option>
                    </select>
                </div>
            </div>

            <!-- Create Service Button -->
            <div class="px-4 py-2 mb-4 flex justify-end">
                <RouterLink to="/createservice"
                    class="flex gap-2 items-center bg-gradient-to-b from-cobalt-700 to-cobalt-900 text-white text-sm
                    md:text-base px-3 py-[6px] md:px-4 md:py-2 rounded-xl hover:shadow-md hover:shadow-cobalt-700/25
                    hover:transition hover:ease-in-out"
                    >
                    Create Service
                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24">
                        <path fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"
                            stroke-width="1.5" d="M18 12h-6m0 0H6m6 0V6m0 6v6" />
                    </svg>
                </RouterLink>
            </div>

            <!-- Loading -->
            <div v-if="servicesStore.isLoading" class="py-8 text-center">
                <SkeltonLoader type="table" size="medium" :rows="10" :columns="7" />
            </div>

            <!-- Error -->
            <div v-else-if="servicesStore.error" class="py-8 text-center" role="alert">
                <div class="text-red-500 mb-4">{{ servicesStore.error }}</div>
                <button @click="servicesStore.fetchServices"
                    class="px-4 py-2 bg-blue-500 text-white rounded-md hover:bg-blue-600 transition-colors">
                    Retry
                </button>
            </div>

            <!-- Empty -->
            <div v-else-if="filteredServices.length === 0" class="py-8 text-center text-gray-500" role="status">
                <span>No services found.</span>
            </div>

            <!-- Table Services -->
            <div v-else class="overflow-x-auto mx-4 rounded-2xl border border-wildsand-200 mb-6">
                <table class="w-full table-auto border-collapse border-t border-b rounded-t-2xl border-wildsand-200"
                    aria-label="Services list">
                    <thead>
                        <tr class="bg-wildsand-50">
                            <th class="px-4 py-2 text-left font-medium uppercase">Title</th>
                            <th class="px-4 py-2 text-left font-medium uppercase">Image</th>
                            <th class="px-4 py-2 text-left font-medium uppercase">Description</th>
                            <th class="px-4 py-2 text-left font-medium uppercase">Location</th>
                            <th class="px-4 py-2 text-left font-medium uppercase">Option</th>
                            <th class="px-4 py-2 text-left font-medium uppercase">Day</th>
                            <th class="px-4 py-2 text-left font-medium uppercase">Time</th>
                            <th class="px-4 py-2 text-left font-medium uppercase">Date</th>
                            <th class="px-4 py-2 text-left font-medium uppercase">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr v-for="service in filteredServices" :key="service.id"
                            class="border-t border-wildsand-200 hover:bg-gray-50">
                            <td class="p-4 text-sm font-medium text-codgray-900">{{ service.title }}</td>
                            <td class="p-4 text-sm">
                                <img v-if="service.image" :src="service.image" alt="Service Image"
                                    class="w-12 h-12 rounded-full" />
                                <span v-else>No Image</span>
                            </td>
                            <td class="p-4 text-sm">{{ service.description }}</td>
                            <td class="p-4 text-sm">{{ service.location }}</td>
                            <td class="p-4 text-sm">{{ Array.isArray(service.option) ? service.option.join(", ") :
                                service.option }}</td>
                            <td class="p-4 text-sm">{{ Array.isArray(service.days) ? service.days.join(", ") :
                                service.days }}</td>
                            <td class="p-4 text-sm">{{ Array.isArray(service.time) ? service.time.join(", ") :
                                service.time }}</td>
                            <!-- Scrollable Date Column -->
                            <td class="p-4 text-sm overflow-y-auto max-h-32">
                                <ul>
                                    <li v-for="d in service.date" :key="d.date">{{ d.day }} - {{ d.date }}</li>
                                </ul>
                            </td>
                            <td class="p-4 text-sm">
                                <!-- Action Buttons -->
                                <button @click="editService(service.id)"
                                    class="px-4 py-2 bg-yellow-500 text-white rounded-md hover:bg-yellow-600 transition-colors">Edit</button>
                                <button @click="deleteService(service.id)"
                                    class="ml-2 px-4 py-2 bg-red-500 text-white rounded-md hover:bg-red-600 transition-colors">Delete</button>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>

        </div>
    </DefaultLayout>
</template>

<script setup>
import { ref, computed, onMounted } from "vue";
import { useServicesStore } from "@/stores/service";
import DefaultLayout from "@/layout/DefaultLayout.vue";
import AlertStatus from "@/components/alert/AlertStatus.vue";
import SkeltonLoader from "@/components/loading-skelton/SkeltonLoader.vue";

const servicesStore = useServicesStore();
const searchQuery = ref("");
const selectedOption = ref("all");

onMounted(() => {
    servicesStore.fetchServices();
});

// Filtered services based on search and selected option
const filteredServices = computed(() => {
    return servicesStore.services.filter((service) => {
        const matchesSearch = service.title.toLowerCase().includes(searchQuery.value.toLowerCase());
        const matchesOption =
            selectedOption.value === "all" || (Array.isArray(service.option) && service.option.includes(selectedOption.value));
        return matchesSearch && matchesOption;
    });
});

// Edit service action
const editService = (id) => {
    console.log("Editing service with ID:", id);
    // Redirect or show a modal for editing the service
};

// Delete service action
const deleteService = (id) => {
    console.log("Deleting service with ID:", id);
    // Implement delete service functionality
    servicesStore.deleteService(id); // Make sure to implement this in your store
};
</script>
