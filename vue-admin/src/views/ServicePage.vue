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

                <!-- Filter Option (Offline / Online / All) -->
                <div class="w-full md:w-64">
                    <select v-model="selectedOption"
                        class="w-full px-4 py-2 border md:border-2 border-wildsand-200 rounded-lg text-codgray-900 font-medium cursor-pointer focus:outline-none focus:ring-2 focus:ring-offset-2 focus:text-cobalt-700 focus:ring-cobalt-600 hover:border-cobalt-500 transition-colors duration-200 ease-in-out text-sm md:text-base">
                        <option value="all">All Options</option>
                        <option value="offline">Offline</option>
                        <option value="online">Online</option>
                    </select>
                </div>
            </div>

            <!-- Loading -->
            <div v-if="servicesStore.isLoading" class="py-8 text-center">
                <SkeltonLoader type="table" size="medium" :rows="10" :columns="5" />
            </div>

            <!-- Error -->
            <div v-else-if="servicesStore.error" class="py-8 text-center" role="alert">
                <div class="text-red-500 mb-4">{{ servicesStore.error }}</div>
                <button @click="servicesStore.fetchServices"
                    class="px-4 py-2 bg-blue-500 text-white rounded-md hover:bg-blue-600 transition-colors focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2">
                    Retry
                </button>
            </div>

            <!-- Empty -->
            <div v-else-if="filteredServices.length === 0" class="py-8 text-center text-gray-500" role="status">
                <span>No services found.</span>
            </div>

            <!-- Tabel Services -->
            <div v-else class="overflow-x-auto mx-4 rounded-2xl border border-wildsand-200 mb-6">
                <table class="w-full table-auto border-collapse border-t border-b rounded-t-2xl border-wildsand-200"
                    aria-label="Services list">
                    <thead>
                        <tr class="bg-wildsand-50">
                            <th class="px-4 py-2 text-left font-medium uppercase">Title</th>
                            <th class="px-4 py-2 text-left font-medium uppercase">Description</th>
                            <th class="px-4 py-2 text-left font-medium uppercase">Location</th>
                            <th class="px-4 py-2 text-left font-medium uppercase">Option</th>
                            <th class="px-4 py-2 text-left font-medium uppercase">Days</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr v-for="service in filteredServices" :key="service.id"
                            class="border-t border-wildsand-200 hover:bg-gray-50">
                            <td class="p-4">
                                <span class="text-sm font-medium text-codgray-900">
                                    {{ service.title }}
                                </span>
                            </td>
                            <td class="p-4">
                                <span class="text-sm">{{ service.description }}</span>
                            </td>
                            <td class="p-4">
                                <span class="text-sm">{{ service.location }}</span>
                            </td>
                            <td class="p-4 capitalize">
                                <span class="text-sm">{{ service.option }}</span>
                            </td>
                            <td class="p-4">
                                <span class="text-sm">{{ Array.isArray(service.days) ? service.days.join(", ") :
                                    service.days }}</span>
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

// Fetch data on mount
onMounted(() => {
    servicesStore.fetchServices();
});

// Computed filtering
const filteredServices = computed(() => {
    return servicesStore.services.filter((service) => {
        const matchesSearch = service.title.toLowerCase().includes(searchQuery.value.toLowerCase());
        const matchesOption = selectedOption.value === "all" || service.option === selectedOption.value;
        return matchesSearch && matchesOption;
    });
});
</script>
