<script setup>
import DefaultLayout from "@/layout/DefaultLayout.vue";
import SkeltonLoader from "@/components/loading-skelton/SkeltonLoader.vue";
import { onMounted, computed } from "vue";
import { useBookingStore } from "@/stores/booking";
import { useServicesStore } from "@/stores/service";
import { useAuthStore } from "@/stores/auth";

const bookingStore = useBookingStore();
const servicesStore = useServicesStore();
const authStore = useAuthStore();

const fetchDataBooking = async () => {
    await bookingStore.fetchAssignedBooking();

    if (authStore.hasPermission('show all booking')) {
        await bookingStore.fetchBookings();
    }
};

const fetchDataService = async () => {
    await servicesStore.fetchAssignedService();

    if (authStore.hasPermission('show all service')) {
        await servicesStore.fetchServices();
    }
};

const FetchDataUser = async () => {
    if (authStore.hasPermission('show user')) {
        await authStore.fetchUsersApi();
    }
};

onMounted(() => {
    fetchDataBooking();
    fetchDataService();
    FetchDataUser();
});


// Summary
const totalBookings = computed(() => bookingStore.bookings.length);
const totalServices = computed(() => servicesStore.services.length);
const totalUsers = computed(() => authStore.users?.length || 0);

// Latest data (limit 5)
const latestBookings = computed(() => bookingStore.bookings.slice(-5));
const latestServices = computed(() => servicesStore.services.slice(-5).reverse());
const latestUsers = computed(() => (authStore.users ? authStore.users.slice(-5).reverse() : []));
</script>
<template>
    <DefaultLayout>
        <div class="min-h-screen flex flex-col gap-6 bg-white p-4 md:p-8 rounded-2xl">
            <h1 class="text-2xl font-bold mb-4">Admin Dashboard</h1>
            <!-- Summary Cards -->
            <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
                <div class="bg-cobalt-700 text-white rounded-xl p-6 flex flex-col items-center">
                    <div class="text-3xl font-bold">{{ totalBookings }}</div>
                    <div class="mt-2">Total Bookings</div>
                </div>
                <div class="bg-cobalt-900 text-white rounded-xl p-6 flex flex-col items-center">
                    <div class="text-3xl font-bold">{{ totalServices }}</div>
                    <div class="mt-2">Total Services</div>
                </div>
                <div class="bg-cobalt-800 text-white rounded-xl p-6 flex flex-col items-center">
                    <div class="text-3xl font-bold">{{ totalUsers }}</div>
                    <div class="mt-2">Total Users</div>
                </div>
            </div>

            <!-- Latest Bookings -->
            <div>
                <h2 class="text-xl font-semibold mb-2">Latest Bookings</h2>
                <div v-if="bookingStore.isLoading">
                    <SkeltonLoader type="table" size="small" :rows="3" :columns="5" />
                </div>
                <table v-else class="min-w-full text-sm text-left border-collapse mb-6">
                    <thead class="bg-wildsand-100">
                        <tr>
                            <th class="px-4 py-2">Service</th>
                            <th class="px-4 py-2">User</th>
                            <th class="px-4 py-2">Status</th>
                            <th class="px-4 py-2">Date</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr v-for="booking in latestBookings" :key="booking.id" class="border-b">
                            <td class="px-4 py-2">{{ booking.service?.title }}</td>
                            <td class="px-4 py-2">{{ booking.user?.email }}</td>
                            <td class="px-4 py-2">{{ booking.service?.status }}</td>
                            <td class="px-4 py-2">{{ booking.service?.date }}</td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <!-- Latest Services -->
            <div>
                <h2 class="text-xl font-semibold mb-2">Latest Services</h2>
                <div v-if="servicesStore.isLoading">
                    <SkeltonLoader type="table" size="small" :rows="3" :columns="5" />
                </div>
                <table v-else class="min-w-full text-sm text-left border-collapse mb-6">
                    <thead class="bg-wildsand-100">
                        <tr>
                            <th class="px-4 py-2">Title</th>
                            <th class="px-4 py-2">Location</th>
                            <th class="px-4 py-2">Option</th>
                            <th class="px-4 py-2">Assigned</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr v-for="service in latestServices" :key="service.id" class="border-b">
                            <td class="px-4 py-2">{{ service.title }}</td>
                            <td class="px-4 py-2">{{ service.location }}</td>
                            <td class="px-4 py-2">{{ Array.isArray(service.option) ? service.option.join(', ') :
                                service.option }}</td>
                            <td class="px-4 py-2">{{ service.user.email }}</td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <!-- Latest Users -->
            <div>
                <h2 class="text-xl font-semibold mb-2">Latest Users</h2>
                <div v-if="!authStore.hasPermission('show user')" class="py-8 text-center text-gray-500" role="status">
                    <span>You have no authorized to show user list</span>
                </div>
                <template v-else>
                    <div v-if="authStore.isLoading">
                        <SkeltonLoader type="table" size="small" :rows="3" :columns="3" />
                    </div>
                    <table v-else class="min-w-full text-sm text-left border-collapse">
                        <thead class="bg-wildsand-100">
                            <tr>
                                <th class="px-4 py-2">Name</th>
                                <th class="px-4 py-2">Email</th>
                                <th class="px-4 py-2">Role</th>
                            </tr>
                        </thead>
                        <div v-if="authStore.users?.length === 0" class="py-8 text-center text-gray-500" role="status">
                            <span>You have no Authorized</span>
                        </div>
                        <tbody>
                            <tr v-for="user in latestUsers" :key="user.id" class="border-b">
                                <td class="px-4 py-2">{{ user.name }}</td>
                                <td class="px-4 py-2">{{ user.email }}</td>
                                <td class="px-4 py-2">{{ user.role.join(', ') }}</td>
                            </tr>
                        </tbody>
                    </table>
                </template>
            </div>
        </div>
    </DefaultLayout>
</template>