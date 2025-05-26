<script setup>
import { ref, computed, onMounted, watch } from 'vue';
import { useBookingStore } from '@/stores/booking';   
import DefaultLayout from "@/layout/DefaultLayout.vue";
import AlertStatus from "@/components/alert/AlertStatus.vue";
import SkeltonLoader from "@/components/loading-skelton/SkeltonLoader.vue";
import PaginationPage from "@/components/pagination/PaginationPage.vue";

const bookingStore = useBookingStore();
const searchQuery = ref("");
const selectedOption = ref("all");
const currentPage = ref(1);
const itemsPerPage = 10;

onMounted(() => {
    bookingStore.fetchBookings();
});

// Filtered bookings based on search and selected option
const filteredBookings = computed(() => {
    return bookingStore.bookings.filter((booking) => {
        const matchesSearch = booking.service?.title
            ?.toLowerCase()
            .includes(searchQuery.value.toLowerCase());
        const matchesOption =
            selectedOption.value === "all" ||
            booking.status === selectedOption.value;
        return matchesSearch && matchesOption;
    });
});

// Total pages based on filtered results
const totalPages = computed(() => {
    return Math.ceil(filteredBookings.value.length / itemsPerPage);
});

// Paginated results from filtered bookings
const paginatedBookings = computed(() => {
    const start = (currentPage.value - 1) * itemsPerPage;
    const end = start + itemsPerPage;
    return filteredBookings.value.slice(start, end);
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
</script>

<template>
    <DefaultLayout class="bg-whiteBgPrimary-100">
        <div class="min-h-screen flex flex-col gap-4 rounded-2xl bg-white p-4 md:p-8">
            <!-- Notifikasi -->
            <AlertStatus :message="bookingStore.notification.message" :type="bookingStore.notification.type"
                :is-visible="bookingStore.notification.show" @close="bookingStore.notification.show = false" />

            <!-- Header Filter dan Search -->
            <div
                class="p-4 bg-white flex flex-col md:flex-row md:items-center md:justify-between md:flex-wrap gap-3 rounded-t-2xl">
                <!-- Search -->
                <div class="w-full md:w-1/3">
                    <input v-model="searchQuery" type="text" placeholder="Search Booking Title"
                        class="w-full px-4 py-2 border md:border-2 border-wildsand-200 rounded-lg text-codgray-900 font-medium cursor-pointer focus:outline-none focus:ring-2 focus:ring-offset-2 focus:text-cobalt-700 focus:ring-cobalt-600 hover:border-cobalt-500 transition-colors duration-200 text-sm md:text-base ease-in-out" />
                </div>

                <!-- Filter Option & Create Button -->
                <div class="w-full md:w-auto flex flex-col md:flex-row items-center gap-3 md:gap-4 justify-end">
                    <!-- Filter Option -->
                    <div class="w-full md:w-64">
                        <select v-model="selectedOption"
                            class="w-full px-4 py-2 border md:border-2 border-wildsand-200 rounded-lg text-codgray-900 font-medium cursor-pointer focus:outline-none focus:ring-2 focus:ring-offset-2 focus:text-cobalt-700 focus:ring-cobalt-600 hover:border-cobalt-500 transition-colors duration-200 ease-in-out text-sm md:text-base">
                            <option value="all">All Options</option>
                            <option value="Pending">Pending</option>
                            <option value="Approved">Approved</option>
                            <option value="Rejected">Rejected</option>
                        </select>
                    </div>
                </div>
            </div>

            <!-- Loading -->
            <div v-if="bookingStore.isLoading" class="py-8 text-center">
                <SkeltonLoader type="table" size="medium" :rows="10" :columns="7" />
            </div>

            <!-- Error
            <div v-else-if="bookingStore.error" class="py-8 text-center" role="alert">
                <div class="text-red-500 mb-4">{{ bookingStore.error }}</div>
                <button @click="bookingStore.fetchbooking"
                    class="px-4 py-2 bg-blue-500 text-white rounded-md hover:bg-blue-600 transition-colors">
                    Retry
                </button>
            </div> -->

            <!-- Empty -->
            <div v-else-if="filteredbookings.length === 0" class="py-8 text-center text-gray-500" role="status">
                <span>No booking found.</span>
            </div>

            <!-- Table booking -->
            <div v-else class="rounded-xl border border-wildsand-200 bg-white shadow-lg shadow-wildsand-100">
                <div class="py-6 px-4 md:px-6 xl:px-7">
                    <h4 class="text-base md:text-xl font-bold text-cobalt-950">Managed Booking</h4>
                </div>
                <div class="overflow-x-auto">
                    <table class="min-w-full text-sm text-left text-codgray-900 border-collapse">
                        <thead class="bg-wildsand-100 text-codgray-950 capitalize text-sm leading-normal">
                            <tr>
                                <th class="px-6 py-3 text-left font-semibold">Service Title</th>
                                <th class="px-6 py-3 text-left font-semibold">User</th>
                                <th class="px-6 py-3 text-left font-semibold">Option</th>
                                <th class="px-6 py-3 text-left font-semibold">Date</th>
                                <th class="px-6 py-3 text-left font-semibold">Time</th>
                                <th class="px-6 py-3 text-left font-semibold">Note</th>
                                <th class="px-6 py-3 text-left font-semibold">Location</th>
                                <th class="px-6 py-3 text-left font-semibold">Status</th>
                                <th class="px-6 py-3 text-left font-semibold">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr v-for="booking in paginatedBookings" :key="booking.id"
                                class="border-b border-wildsand-200 hover:bg-wildsand-50 transition-colors duration-150">
                                <td class="px-6 py-4 font-medium">{{ booking.service.title }}</td>
                                <td class="px-6 py-4 font-medium">{{ booking.user.name }}</td>
                                <td class="px-6 py-4 font-medium">{{ booking.option }}</td>
                                <td class="px-6 py-4 font-medium">{{ booking.date }}</td>
                                <td class="px-6 py-4 font-medium">{{ booking.time }}</td>
                                <td class="px-6 py-4 font-medium">{{ booking.note }}</td>
                                <td class="px-6 py-4 font-medium">{{ booking.location }}</td>
                                <td class="px-6 py-4">
                                    <span
                                        :class="{
                                            'bg-yellow-100 text-yellow-800': booking.status === 'Pending',
                                            'bg-green-100 text-green-800': booking.status === 'Approved',
                                            'bg-red-100 text-red-800': booking.status === 'Rejected'
                                        }"
                                        class="inline-flex items-center px-3 py-1 rounded-full text-xs font-semibold">
                                        {{ booking.status }}
                                    </span>
                                </td>
                                <td class="px-6 py-4">
                                    <div class="flex items-center justify-center gap-6 h-full">
                                        <button title="Delete" class="text-red-500">
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
                                                    <h2 class="text-lg font-semibold text-gray-800">Confirm Delete</h2>
                                                    <p class="text-gray-600 mt-2">Are you sure you want to delete this
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

                                        <RouterLink title="Edit" >
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
                </div>
                <!-- Pagination Controls -->
                <PaginationPage :current-page="currentPage" :total-pages="totalPages" :has-next-page="hasNextPage"
                    :has-prev-page="hasPrevPage" @page-change="handlePageChange" />
            </div>
        </div>
    </DefaultLayout>
</template>