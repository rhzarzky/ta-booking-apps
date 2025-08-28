<script setup>
import { ref, onMounted, computed, toRefs, watch, nextTick } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useServicesStore } from '@/stores/service'
import { useMapStore } from '@/stores/map'
import DefaultLayout from '@/layout/DefaultLayout.vue'
import VueCal from 'vue-cal'
import 'vue-cal/dist/vuecal.css'

const route = useRoute()
const router = useRouter()
const mapStore = useMapStore();
const servicesStore = useServicesStore()
const showDeleteModal = ref(false)

const service = ref(null)

const fetchService = async () => {
    try {
        const id = route.params.id
        const response = await servicesStore.fetchServiceDetail(id)
        service.value = response
    } catch (error) {
        console.error('Failed to fetch service:', error)
        router.push('/service') // Redirect on error
    }
}

// VueCal configuration
const events = computed(() => {
    if (!service.value?.date) return []

    return service.value.date.map(d => ({
        start: d.date,
        end: d.date,
        title: d.day,
        background: '#D6E4FF',
        color: '#1858DD'
    }))
})

onMounted(() => {
    fetchService()
})

const {
    mapContainer,
    initMap,
    location,
    lng,
    lat
} = toRefs(mapStore);

// Sync map data
watch([location, lng, lat], () => {
    service.location = location.value;
    service.longitude = lng.value;
    service.latitude = lat.value;
});

// Initialize map when service data is available
watch(service, async (val) => {
    if (val && val.longitude && val.latitude) {
        lng.value = parseFloat(val.longitude);
        lat.value = parseFloat(val.latitude);

        await nextTick();
        initMap.value();
    }
});

const confirmDelete = () => {
    showDeleteModal.value = true
}

const handleDeleteConfirmed = async () => {
    try {
        await servicesStore.deleteService(service.value.id)
        servicesStore.showNotification('Service deleted successfully.', 'success')
        router.push('/service')
    } catch (error) {
        console.error('Delete failed:', error)
        servicesStore.showNotification('Failed to delete service.', 'error')
    } finally {
        showDeleteModal.value = false
    }
}
</script>

<template>
    <DefaultLayout class="bg-whiteBgPrimary-100">
        <div class="min-h-screen p-6 md:p-10 bg-white rounded-2xl shadow-md w-full mx-auto">
            <!-- Header with Back Button and Title -->
            <div class="flex items-center justify-between mt-6 mb-6">
                <h1 class="text-2xl md:text-3xl font-bold text-cobalt-950">Service Detail</h1>
                <RouterLink to="/service"
                    class="inline-flex items-center gap-2 px-4 py-2 text-sm bg-gray-100 text-cobalt-900 rounded hover:bg-gray-200">
                    <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4" fill="none" viewBox="0 0 24 24"
                        stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
                    </svg>
                    Back to Services
                </RouterLink>
            </div>
            <div v-if="service" class="space-y-4">
                <div class="flex items-center gap-4">
                    <img v-if="service.image" :src="service.image" alt="Service Image"
                        class="w-32 h-32 rounded-lg object-cover shadow-md" />
                    <div>
                        <h2 class="text-xl font-semibold text-cobalt-800">{{ service.title }}</h2>
                        <p class="text-gray-600">{{ service.description }}</p>
                    </div>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div class="p-4 border rounded-lg">
                        <p class="text-sm text-gray-500">Location</p>
                        <p class="text-cobalt-900 font-medium">{{ service.location }}</p>
                        <!-- Mapbox container -->
                        <div ref="mapContainer" class="h-96 w-full rounded-xl"></div>
                    </div>
                    <div class="p-4 border rounded-lg">
                        <p class="text-sm text-gray-500">Times</p>
                        <p class="text-cobalt-900 font-medium">
                            {{ Array.isArray(service.time) ? service.time.join(', ') : service.time }}
                        </p>
                    </div>
                    <div class="p-4 border rounded-lg">
                        <p class="text-sm text-gray-500">Option</p>
                        <p class="text-cobalt-900 font-medium">
                            {{ Array.isArray(service.option) ? service.option.join(', ') : service.option }}
                        </p>
                    </div>
                    <div class="p-4 border rounded-lg">
                        <p class="text-sm text-gray-500">Days</p>
                        <p class="text-cobalt-900 font-medium">
                            {{ Array.isArray(service.days) ? service.days.join(', ') : service.days }}
                        </p>
                    </div>
                    <div class="p-4 border rounded-lg col-span-full">
                        <p class="text-sm text-gray-500 mb-2">Available Dates</p>
                        <VueCal style="height: 400px" hide-view-selector default-view="month" :events="events"
                            :disable-views="['week', 'day', 'year']" active-view="month" :time="false" readonly />
                    </div>
                </div>

                <div class="flex justify-end gap-4 mt-6">
                    <RouterLink :to="`/edit-service/${service.id}`"
                        class="px-4 py-2 bg-yellow-500 text-white rounded hover:bg-yellow-600">
                        Edit
                    </RouterLink>
                    <button @click="confirmDelete" class="px-4 py-2 bg-red-600 text-white rounded hover:bg-red-700">
                        Delete
                    </button>
                </div>
            </div>

            <!-- Delete Modal -->
            <transition name="fade">
                <div v-if="showDeleteModal"
                    class="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50">
                    <div class="bg-white p-6 rounded-lg w-full max-w-md shadow-lg">
                        <h2 class="text-lg font-semibold text-gray-800">Confirm Delete</h2>
                        <p class="text-gray-600 mt-2">Are you sure you want to delete this service?</p>
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
        </div>
    </DefaultLayout>
</template>
