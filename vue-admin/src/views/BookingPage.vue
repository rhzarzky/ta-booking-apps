<script setup>
import { ref, computed, onMounted, watch } from 'vue';
import { useBookingStore } from '@/stores/booking';
import { useAuthStore } from '@/stores/auth';
import DefaultLayout from "@/layout/DefaultLayout.vue";
import AlertStatus from "@/components/alert/AlertStatus.vue";
import SkeltonLoader from "@/components/loading-skelton/SkeltonLoader.vue";
import PaginationPage from "@/components/pagination/PaginationPage.vue";

const bookingStore = useBookingStore();
const authStore = useAuthStore();
const searchQuery = ref("");
const selectedOption = ref("all");
const currentPage = ref(1);
const itemsPerPage = 10;
const actionType = ref(null);
const bookingToConfirm = ref(null);
const showConfirmationModal = ref(false);

const fetchData = async () => {
    await bookingStore.fetchAssignedBooking();

    if (authStore.hasPermission('show all booking')) {
        await bookingStore.fetchBookings();
    }
};

onMounted(() => {
    fetchData();
});

// Filtered bookings based on search and selected option
const filteredBookings = computed(() => {
    return bookingStore.bookings.filter((booking) => {
        const matchesSearch = booking.service?.title
            ?.toLowerCase()
            .includes(searchQuery.value.toLowerCase());
        const matchesOption =
            selectedOption.value === "all" ||
            booking.service.status === selectedOption.value;
        return matchesSearch && matchesOption;
    });
});

// Total pages based on filtered results
const totalPages = computed(() => {
    return Math.ceil(filteredBookings.value.length / itemsPerPage);
});

// Paginated results from filtered bookings
const paginatedBookings = computed(() => {
    const sorted = [...filteredBookings.value].sort((a, b) => b.id_booking - a.id_booking);
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

// Show modal for confirmation
const handleAction = (booking, type) => {
    bookingToConfirm.value = booking;
    actionType.value = type;
    showConfirmationModal.value = true;
};

const closeConfirmationModal = () => {
    showConfirmationModal.value = false;
    bookingToConfirm.value = null;
    actionType.value = null;
};

// Admin note for additional information
const adminNote = ref("");

const handleConfirmation = async () => {
    if (!bookingToConfirm.value || !actionType.value) return;

    const validStatuses = ['Approved', 'Declined'];
    const status = validStatuses.includes(actionType.value) ? actionType.value : 'Pending';

    const formData = new FormData();
    formData.append('status', status);
    formData.append("note", adminNote.value);

    await bookingStore.confirmBooking(bookingToConfirm.value.id_booking, formData);
    await fetchData();

    closeConfirmationModal();
};

const isActionDisabled = (booking) => {
    return ['Approved', 'Declined'].includes(booking.service.status);
};
</script>

<template>
    <DefaultLayout class="bg-whiteBgPrimary-100">
        <div class="min-h-screen flex flex-col gap-4 rounded-2xl bg-white p-4 md:p-8">
            <div class="w-full flex flex-wrap gap-3 items-center">
                <!-- Notifikasi -->
                <AlertStatus :message="bookingStore.notification.message" :type="bookingStore.notification.type"
                    :is-visible="bookingStore.notification.show" @close="bookingStore.notification.show = false" />

                <!-- Header Filter dan Search -->
                <div
                    class="p-4 bg-white flex flex-col md:flex-row md:items-center md:justify-between md:gap-4 gap-3 rounded-t-2xl w-full flex-wrap">
                    <!-- Search -->
                    <div class="flex-1 min-w-0">
                        <input v-model="searchQuery" type="text" placeholder="Search Booking Title"
                            class="w-full px-4 py-2 border md:border-2 border-wildsand-200 rounded-lg text-codgray-900 font-medium cursor-pointer focus:outline-none focus:ring-2 focus:ring-offset-2 focus:text-cobalt-700 focus:ring-cobalt-600 hover:border-cobalt-500 transition-colors duration-200 text-sm md:text-base ease-in-out" />
                    </div>

                    <!-- Filter Option -->
                    <div class="flex flex-wrap gap-3 justify-end md:justify-start items-center">
                        <!-- Filter Option -->
                        <div class="w-full md:w-64">
                            <select v-model="selectedOption"
                                class="w-full px-4 py-2 border md:border-2 border-wildsand-200 rounded-lg text-codgray-900 font-medium cursor-pointer focus:outline-none focus:ring-2 focus:ring-offset-2 focus:text-cobalt-700 focus:ring-cobalt-600 hover:border-cobalt-500 transition-colors duration-200 ease-in-out text-sm md:text-base">
                                <option value="all">All Options</option>
                                <option value="Pending">Pending</option>
                                <option value="Approved">Approved</option>
                                <option value="Declined">Declined</option>
                            </select>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Loading -->
            <div v-if="bookingStore.isLoading" class="py-8 text-center">
                <SkeltonLoader type="table" size="medium" :rows="10" :columns="7" />
            </div>

            <!-- Empty -->
            <div v-else-if="filteredBookings.length === 0" class="py-8 text-center text-gray-500" role="status">
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
                                <th class="px-6 py-3 text-left font-semibold">No.</th>
                                <th class="px-6 py-3 text-left font-semibold w-56">Service Title</th>
                                <th class="px-6 py-3 text-left font-semibold">Option</th>
                                <th class="px-7 py-3 text-left font-semibold">Date</th>
                                <th class="px-6 py-3 text-left font-semibold">Time</th>
                                <th class="px-6 py-3 text-left font-semibold">Booked by</th>
                                <th class="px-6 py-3 text-left font-semibold">Location</th>
                                <th class="px-6 py-3 text-left font-semibold">Note</th>
                                <th class="px-6 py-3 text-left font-semibold">Status</th>
                                <th class="px-6 py-3 text-left font-semibold">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr v-for="booking in paginatedBookings" :key="booking.id"
                                class="border-b border-wildsand-200 hover:bg-wildsand-50 transition-colors duration-150">
                                <td class="px-6 py-4 font-medium whitespace-nowrap">
                                    {{ (currentPage - 1) * itemsPerPage + (paginatedBookings.indexOf(booking) + 1) }}
                                </td>
                                <td class="px-6 py-4 font-medium">{{ booking.service.title }}</td>
                                <td class="px-6 py-4 font-medium">{{ booking.service.option }}</td>
                                <td class="px-7 py-4 font-medium whitespace-nowrap">
                                    {{ booking.service.date ? booking.service.date.split('-').reverse().join('-') : ''
                                    }}
                                </td>
                                <td class="px-6 py-4 font-medium">{{ booking.service.time }}</td>
                                <td class="px-6 py-4 font-medium">{{ booking.user.email }}</td>
                                <td class="px-6 py-4 font-medium">{{ booking.service.location }}</td>
                                <td class="px-6 py-4 font-medium">{{ booking.service.note }}</td>
                                <td class="px-6 py-4">
                                    <span :class="{
                                        'bg-yellow-100 text-yellow-800': booking.service.status === 'Pending',
                                        'bg-green-100 text-green-800': booking.service.status === 'Approved',
                                        'bg-red-100 text-red-800': booking.service.status === 'Declined',
                                    }" class="inline-flex items-center px-3 py-1 rounded-full text-xs font-semibold">
                                        {{ booking.service.status }}
                                    </span>
                                </td>
                                <td class="px-6 py-4">
                                    <div class="flex items-center justify-center gap-6 h-full">
                                        <!-- Approved Button -->
                                        <button title="Approved" class="text-green-600 hover:text-green-800"
                                            :class="{ 'opacity-50 cursor-not-allowed': isActionDisabled(booking) }"
                                            :disabled="isActionDisabled(booking)"
                                            @click="handleAction(booking, 'Approved')">
                                            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24"
                                                viewBox="0 0 24 24">
                                                <path fill="#109b06"
                                                    d="M18.577 6.183a1 1 0 0 1 .24 1.394l-5.666 8.02c-.36.508-.665.94-.94 1.269c-.287.34-.61.658-1.038.86a2.83 2.83 0 0 1-2.03.153c-.456-.137-.82-.406-1.149-.702c-.315-.285-.672-.668-1.09-1.116l-1.635-1.753a1 1 0 1 1 1.462-1.364l1.606 1.722c.455.487.754.806.998 1.027c.24.216.344.259.385.271c.196.06.405.045.598-.046c.046-.022.149-.085.36-.338c.216-.257.473-.62.863-1.171l5.642-7.986a1 1 0 0 1 1.394-.24" />
                                            </svg>
                                        </button>

                                        <!-- Declined Button -->
                                        <button title="Declined" class="text-red-600 hover:text-red-800"
                                            :class="{ 'opacity-50 cursor-not-allowed': isActionDisabled(booking) }"
                                            :disabled="isActionDisabled(booking)"
                                            @click="handleAction(booking, 'Declined')">
                                            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24"
                                                viewBox="0 0 24 24">
                                                <path fill="none" stroke="#d60000" stroke-linecap="round"
                                                    stroke-linejoin="round" stroke-width="1.5"
                                                    d="M19 5L5 19M5 5l14 14" />
                                            </svg>
                                        </button>

                                        <!-- Modal for Confirmation -->
                                        <transition name="fade">
                                            <div v-if="showConfirmationModal"
                                                class="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50">
                                                <div class="bg-white p-6 rounded-lg w-full max-w-md shadow-lg"
                                                    role="dialog" aria-modal="true">
                                                    <h2 class="text-lg font-semibold text-gray-800">
                                                        Confirm
                                                        <span v-if="actionType === 'Approved'">Approval</span>
                                                        <span v-else-if="actionType === 'Declined'">Rejection</span>
                                                    </h2>
                                                    <p class="text-gray-600 mt-2">
                                                        Are you sure you want to
                                                        <span v-if="actionType === 'Approved'">approve</span>
                                                        <span v-else-if="actionType === 'Declined'">decline</span>
                                                        this booking?
                                                    </p>

                                                    <!-- Note Input -->
                                                    <div v-if="['Declined'].includes(actionType)" class="mt-4">
                                                        <label for="admin-note" class="text-sm text-gray-600">Note
                                                            (optional)</label>
                                                        <textarea id="admin-note" v-model="adminNote"
                                                            class="w-full mt-1 border rounded p-2 text-sm" rows="3"
                                                            placeholder="Write a reason or note for this action...">
                                                        </textarea>
                                                    </div>

                                                    <div class="mt-4 flex justify-end gap-2">
                                                        <button @click="closeConfirmationModal"
                                                            class="px-4 py-2 text-sm bg-gray-200 text-gray-800 rounded hover:bg-gray-300">
                                                            Cancel
                                                        </button>
                                                        <button @click="handleConfirmation" :class="[
                                                            'px-4 py-2 text-sm text-white rounded',
                                                            actionType === 'Approved'
                                                                ? 'bg-green-600 hover:bg-green-700'
                                                                : actionType === 'Declined'
                                                                    ? 'bg-red-600 hover:bg-red-700'
                                                                    : 'bg-blue-600 hover:bg-blue-700'
                                                        ]">
                                                            Confirm
                                                        </button>
                                                    </div>
                                                </div>
                                            </div>
                                        </transition>
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