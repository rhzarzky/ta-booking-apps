<script setup>
import { ref, computed, onMounted, watch } from "vue";
import { useServicesStore } from "@/stores/service";
import { useAuthStore } from "@/stores/auth";
import DefaultLayout from "@/layout/DefaultLayout.vue";
import AlertStatus from "@/components/alert/AlertStatus.vue";
import SkeltonLoader from "@/components/loading-skelton/SkeltonLoader.vue";
import PaginationPage from "@/components/pagination/PaginationPage.vue";

const servicesStore = useServicesStore();
const authStore = useAuthStore();
const searchQuery = ref("");
const selectedOption = ref("all");
const currentPage = ref(1);
const itemsPerPage = 10;
const showDeleteModal = ref(false);
const serviceToDelete = ref(null);
const isImageModalVisible = ref(false);
const modalImageUrl = ref("");

const fetchData = async () => {
    await servicesStore.fetchAssignedService();

    if (authStore.hasPermission('show all service')) {
        await servicesStore.fetchServices();
    }
};

onMounted(() => {
    fetchData();
});

// Filtered services based on search and selected option
const filteredServices = computed(() => {
    return servicesStore.services.filter((service) => {
        const matchesSearch = service.title.toLowerCase().includes(searchQuery.value.toLowerCase());
        const matchesOption =
            selectedOption.value === "all" ||
            (Array.isArray(service.option) && service.option.includes(selectedOption.value));
        return matchesSearch && matchesOption;
    });
});

// Total pages based on filtered results
const totalPages = computed(() => {
    return Math.ceil(filteredServices.value.length / itemsPerPage);
});

// Paginated results from filtered services, sorted by service id descending
const paginatedServices = computed(() => {
    const sorted = [...filteredServices.value].sort((a, b) => a.id - b.id);
    const start = (currentPage.value - 1) * itemsPerPage;
    const end = start + itemsPerPage;
    return sorted.slice(start, end);
});

// Page navigation
const handlePageChange = (page) => {
    currentPage.value = page;
};

// Has next/prev page
const hasNextPage = computed(() => currentPage.value < totalPages.value);
const hasPrevPage = computed(() => currentPage.value > 1);

// Reset pagination when filter/search changes
watch([searchQuery, selectedOption], () => {
    currentPage.value = 1;
});

// Show date modal
const isDateModalVisible = ref(false)
const selectedDates = ref([])

function openDateModal(dates) {
    selectedDates.value = dates.map(d => d.date)
    isDateModalVisible.value = true
}

function closeDateModal() {
    isDateModalVisible.value = false
}

// Delete service Confirmation
const confirmDelete = (id) => {
    serviceToDelete.value = id;
    showDeleteModal.value = true;
};

const handleDeleteConfirmed = async () => {
    try {
        await servicesStore.deleteService(serviceToDelete.value);
        servicesStore.showNotification("Service deleted successfully.", "success");
    } catch (err) {
        console.error("Error deleting service:", err);
        if (err.response && err.response.status === 403) {
            servicesStore.showNotification(err.response.data.responseMessage, "error");
        } else {
            servicesStore.showNotification("Failed to delete service.", "error");
        }
    } finally {
        showDeleteModal.value = false;
        serviceToDelete.value = null;
    }
};

// Function to open image modal
function openImageModal(imageUrl) {
    modalImageUrl.value = imageUrl;
    isImageModalVisible.value = true;
}
// Function to close image modal
function closeImageModal() {
    isImageModalVisible.value = false;
    modalImageUrl.value = "";
}

// Function to show service description
const modalDescription = ref("");
const isDescriptionModalVisible = ref(false);

function showDescription(description) {
    modalDescription.value = description;
    isDescriptionModalVisible.value = true;
}

function closeDescriptionModal() {
    isDescriptionModalVisible.value = false;
    modalDescription.value = "";
}

// Function to show location modal
const modalLocation = ref("");
const isLocationModalVisible = ref(false);

function showLocation(location) {
    modalLocation.value = location;
    isLocationModalVisible.value = true;
}

function closeLocationModal() {
    isLocationModalVisible.value = false;
    modalLocation.value = "";
}
</script>

<template>
    <DefaultLayout class="bg-whiteBgPrimary-100">
        <div class="min-h-screen flex flex-col gap-4 rounded-2xl bg-white p-4 md:p-8">
            <div class="w-full flex flex-wrap gap-3 items-center">
                <!-- Notifikasi -->
                <AlertStatus :message="servicesStore.notification.message" :type="servicesStore.notification.type"
                    :is-visible="servicesStore.notification.show" @close="servicesStore.notification.show = false" />

                <!-- Search -->
                <input v-model="searchQuery" type="text" placeholder="Search Service Title"
                    class="flex-1 min-w-0 px-4 py-2 border md:border-2 border-wildsand-200 rounded-lg text-codgray-900 font-medium cursor-pointer focus:outline-none focus:ring-2 focus:ring-offset-2 focus:text-cobalt-700 focus:ring-cobalt-600 hover:border-cobalt-500 transition-colors duration-200 text-sm md:text-base ease-in-out" />

                <!-- Filter Option -->
                <div class="w-full md:w-64">
                    <select v-model="selectedOption"
                        class="w-full px-4 py-2 border md:border-2 border-wildsand-200 rounded-lg text-codgray-900 font-medium cursor-pointer focus:outline-none focus:ring-2 focus:ring-offset-2 focus:text-cobalt-700 focus:ring-cobalt-600 hover:border-cobalt-500 transition-colors duration-200 ease-in-out text-sm md:text-base">
                        <option value="all">All Options</option>
                        <option value="Offline">Offline</option>
                        <option value="Online">Online</option>
                    </select>
                </div>

                <!-- Create Service Button -->
                <RouterLink to="/create-service"
                    class="flex gap-2 items-center bg-gradient-to-b from-cobalt-700 to-cobalt-900 text-white text-sm md:text-base px-3 py-[6px] md:px-4 md:py-2 rounded-xl hover:shadow-md hover:shadow-cobalt-700/25 hover:transition hover:ease-in-out">
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

            <!-- Error
            <div v-else-if="servicesStore.error" class="py-8 text-center" role="alert">
                <div class="text-red-500 mb-4">{{ servicesStore.error }}</div>
                <button @click="servicesStore.fetchServices"
                    class="px-4 py-2 bg-blue-500 text-white rounded-md hover:bg-blue-600 transition-colors">
                    Retry
                </button>
            </div> -->

            <!-- Empty -->
            <div v-else-if="filteredServices.length === 0" class="py-8 text-center text-gray-500" role="status">
                <span>No services found.</span>
            </div>

            <!-- Table Services -->
            <div v-else class="rounded-xl border border-wildsand-200 bg-white shadow-lg shadow-wildsand-100">
                <div class="py-6 px-4 md:px-6 xl:px-7">
                    <h4 class="text-base md:text-xl font-bold text-cobalt-950">Managed Service</h4>
                </div>
                <div class="overflow-x-auto">
                    <table class="min-w-full text-sm text-left text-codgray-900 border-collapse">
                        <thead class="bg-wildsand-100 text-codgray-950 capitalize text-sm leading-normal">
                            <tr>
                                <th class="px-4 py-3 font-semibold whitespace-nowrap">ID</th>
                                <th class="px-4 py-3 font-semibold whitespace-nowrap">Title</th>
                                <th class="px-4 py-3 font-semibold whitespace-nowrap">Image</th>
                                <th class="px-4 py-3 font-semibold whitespace-nowrap w-72">Description</th>
                                <th class="px-4 py-3 font-semibold whitespace-nowrap">Assigned</th>
                                <th class="px-4 py-3 font-semibold whitespace-nowrap w-56">Location</th>
                                <th class="px-4 py-3 font-semibold whitespace-nowrap">Option</th>
                                <th class="px-4 py-3 font-semibold whitespace-nowrap">Day</th>
                                <th class="px-4 py-3 font-semibold whitespace-nowrap">Time</th>
                                <th class="px-4 py-3 font-semibold whitespace-nowrap">Date</th>
                                <th class="px-4 py-3 font-semibold whitespace-nowrap">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr v-for="service in paginatedServices" :key="service.id"
                                class="border-b border-wildsand-200 hover:bg-wildsand-50 transition-colors duration-150 align-top">
                                <td class="px-4 py-4 font-medium whitespace-nowrap">{{ service.id }}</td>
                                <td class="px-4 py-4 font-medium whitespace-nowrap">{{ service.title }}</td>
                                <td class="px-4 py-4 font-medium whitespace-nowrap">
                                    <img v-if="service.image" :src="service.image" alt="Service Image"
                                        class="w-10 h-10 rounded-full object-cover cursor-pointer"
                                        @click="openImageModal(service.image)" />
                                    <span v-else class="text-gray-400 italic">No Image</span>
                                </td>
                                <td class="px-4 py-4 font-medium max-w-xs break-words whitespace-pre-line">
                                    <div class="line-clamp-3" title="Click to show detail"
                                        @click="showDescription(service.description)" style="cursor:pointer;">
                                        {{ service.description }}
                                    </div>
                                </td>
                                <!-- Description Modal -->
                                <div v-if="isDescriptionModalVisible"
                                    class="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50">
                                    <div class="bg-white rounded-xl shadow-lg max-w-2xl w-full p-6">
                                        <div class="flex justify-between items-start mb-4">
                                            <h3 class="text-lg font-semibold text-codgray-900">Service Description</h3>
                                            <button @click="closeDescriptionModal"
                                                class="text-gray-500 hover:text-gray-800">
                                                <svg xmlns="http://www.w3.org/2000/svg" class="w-6 h-6" fill="none"
                                                    viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                                                    <path stroke-linecap="round" stroke-linejoin="round"
                                                        d="M6 18L18 6M6 6l12 12" />
                                                </svg>
                                            </button>
                                        </div>
                                        <p class="text-codgray-700 whitespace-pre-line">{{ modalDescription }}</p>
                                    </div>
                                </div>
                                <td class="px-4 py-4 font-medium whitespace-nowrap">{{ service.user.email }}</td>
                                <td class="px-4 py-4 font-medium max-w-xs break-words whitespace-pre-line">
                                    <div class="line-clamp-2" title="Click to show detail"
                                        @click="showLocation(service.location)" style="cursor:pointer;">
                                        {{ service.location }}
                                    </div>
                                </td>
                                <!-- Location Modal -->
                                <div v-if="isLocationModalVisible"
                                    class="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50">
                                    <div class="bg-white rounded-xl shadow-lg max-w-2xl w-full p-6">
                                        <div class="flex justify-between items-start mb-4">
                                            <h3 class="text-lg font-semibold text-codgray-900">Service Location</h3>
                                            <button @click="closeLocationModal"
                                                class="text-gray-500 hover:text-gray-800">
                                                <svg xmlns="http://www.w3.org/2000/svg" class="w-6 h-6" fill="none"
                                                    viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                                                    <path stroke-linecap="round" stroke-linejoin="round"
                                                        d="M6 18L18 6M6 6l12 12" />
                                                </svg>
                                            </button>
                                        </div>
                                        <p class="text-codgray-700 whitespace-pre-line">{{ modalLocation }}</p>
                                    </div>
                                </div>
                                <td class="px-4 py-4 font-medium whitespace-nowrap">
                                    {{ Array.isArray(service.option) ? service.option.join(", ") : service.option }}
                                </td>
                                <td class="px-4 py-4 font-medium whitespace-nowrap">
                                    {{ Array.isArray(service.days) ? service.days.join(", ") : service.days }}
                                </td>
                                <td class="px-4 py-4 font-medium whitespace-nowrap">
                                    {{ Array.isArray(service.time) ? service.time.join(", ") : service.time }}
                                </td>
                                <td class="px-4 py-4 font-medium whitespace-nowrap">
                                    <button class="text-cobalt-700 underline hover:text-cobalt-900"
                                        @click="openDateModal(service.date)">
                                        Show
                                    </button>
                                    <!-- Modal Calendar -->
                                    <div v-if="isDateModalVisible"
                                        class="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50">
                                        <div class="bg-white rounded-xl shadow-xl p-6 w-full max-w-md">
                                            <div class="flex justify-between items-center mb-4">
                                                <h2 class="text-lg font-semibold text-cobalt-900">Available Date
                                                </h2>
                                                <button @click="closeDateModal"
                                                    class="text-gray-500 hover:text-red-500 text-lg">&times;</button>
                                            </div>
                                            <div class="grid grid-cols-4 gap-2">
                                                <div v-for="date in selectedDates" :key="date"
                                                    class="border p-2 text-center rounded bg-cobalt-50 text-cobalt-900 text-sm">
                                                    {{ new Date(date).toLocaleDateString() }}
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </td>
                                <td class="px-4 py-4 whitespace-nowrap">
                                    <div class="flex items-center justify-center gap-6 h-full">
                                        <button @click="confirmDelete(service.id)" title="Delete" class="text-red-500">
                                            <!-- Delete Icon -->
                                            <svg width="24" height="24" viewBox="0 0 24 24" fill="none"
                                                xmlns="http://www.w3.org/2000/svg">
                                                <path
                                                    d="M18 9L17.16 17.398C17.033 18.671 16.97 19.307 16.68 19.788C16.4257 20.2114 16.0516 20.55 15.605 20.761C15.098 21 14.46 21 13.18 21H10.82C9.541 21 8.902 21 8.395 20.76C7.94805 20.5491 7.57361 20.2106 7.319 19.787C7.031 19.307 6.967 18.671 6.839 17.398L6 9M13.5 15.5V10.5M10.5 15.5V10.5M4.5 6.5H9.115M9.115 6.5L9.501 3.828C9.613 3.342 10.017 3 10.481 3H13.519C13.983 3 14.386 3.342 14.499 3.828L14.885 6.5M9.115 6.5H14.885M14.885 6.5H19.5"
                                                    stroke="#E20E0E" stroke-width="1.5" stroke-linecap="round"
                                                    stroke-linejoin="round" />
                                            </svg>
                                        </button>
                                        <transition name="fade">
                                            <div v-if="showDeleteModal"
                                                class="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50">
                                                <div class="bg-white p-6 rounded-lg w-full max-w-md shadow-lg">
                                                    <h2 class="text-lg font-semibold text-gray-800">Confirm Delete
                                                    </h2>
                                                    <p class="text-gray-600 mt-2">Are you sure you want to delete
                                                        this
                                                        service?</p>
                                                    <div class="mt-4 flex justify-end gap-2">
                                                        <button @click="showDeleteModal = false"
                                                            class="px-4 py-2 text-sm bg-gray-200 rounded hover:bg-gray-300">
                                                            Cancel
                                                        </button>
                                                        <button @click="handleDeleteConfirmed"
                                                            class="px-4 py-2 text-sm bg-red-600 text-white rounded hover:bg-red-700">
                                                            Delete
                                                        </button>
                                                    </div>
                                                </div>
                                            </div>
                                        </transition>
                                        <RouterLink title="Edit" :to="`/edit-service/${service.id}`">
                                            <!-- Edit Icon -->
                                            <svg width="24" height="24" viewBox="0 0 24 24" fill="none"
                                                xmlns="http://www.w3.org/2000/svg">
                                                <path
                                                    d="M15 6L18 9M13 20H21M5 16L4 20L8 19L19.586 7.414C19.9609 7.03895 20.1716 6.53033 20.1716 6C20.1716 5.46967 19.9609 4.96106 19.586 4.586L19.414 4.414C19.0389 4.03906 18.5303 3.82843 18 3.82843C17.4697 3.82843 16.9611 4.03906 16.586 4.414L5 16Z"
                                                    stroke="#1858DD" stroke-linecap="round" stroke-linejoin="round" />
                                            </svg>
                                        </RouterLink>
                                    </div>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                    <!-- Image Modal -->
                    <div v-if="isImageModalVisible"
                        class="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-60">
                        <div
                            class="relative bg-white rounded-xl shadow-xl p-4 max-w-lg w-full flex flex-col items-center">
                            <button @click="closeImageModal"
                                class="absolute top-2 right-2 text-gray-500 hover:text-red-500 text-2xl">&times;</button>
                            <img :src="modalImageUrl" alt="Service Image"
                                class="max-h-[70vh] w-auto rounded-lg object-contain" />
                        </div>
                    </div>
                </div>
                <!-- Pagination Controls -->
                <PaginationPage :current-page="currentPage" :total-pages="totalPages" :has-next-page="hasNextPage"
                    :has-prev-page="hasPrevPage" @page-change="handlePageChange" />
            </div>
        </div>
    </DefaultLayout>
</template>
