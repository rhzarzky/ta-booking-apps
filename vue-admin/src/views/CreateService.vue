<script setup>
import { reactive, ref, onMounted, watch } from "vue";
import { useRouter } from "vue-router";
import DefaultLayout from "@/layout/DefaultLayout.vue";
import { useServicesStore } from "@/stores/service";
import { useMapsStore } from "@/stores/map";
import AlertStatus from "@/components/alert/AlertStatus.vue";
import mapboxgl from 'mapbox-gl';
import axios from 'axios';

const servicesStore = useServicesStore();
const mapsStore = useMapsStore();
const router = useRouter();

const post = reactive({
    image: null,
    title: "",
    description: "",
    location: "",
    longitude: 0,
    latitude: 0,
    option: [],
    time: [],
    days: [],
    end_date: "",
});

// Validation errors
const validation = ref([]);
const notification = ref("");
const rangeStart = ref("");
const rangeEnd = ref("");

// Function for canceling the form
const cancel = () => {
    router.push({ path: "/service" });
};

// Generate times based on the range start and end
function generateTimes() {
    if (!rangeStart.value || !rangeEnd.value) return;
    const start = rangeStart.value.split(":").map(Number);
    const end = rangeEnd.value.split(":").map(Number);
    let current = new Date();
    current.setHours(start[0], start[1], 0, 0);
    const endTime = new Date();
    endTime.setHours(end[0], end[1], 0, 0);
    const times = [];
    while (current <= endTime) {
        const h = current.getHours().toString().padStart(2, "0");
        const m = current.getMinutes().toString().padStart(2, "0");
        times.push(`${h}:${m}`);
        current.setHours(current.getHours() + 1);
    }
    post.time = times;
}

// Mapbox configuration
mapboxgl.accessToken = import.meta.env.VITE_MAPBOX_ACCESS_TOKEN

const mapContainer = ref(null)
const map = ref(null)
const marker = ref(null)

const lng = ref(106.816666) // default Jakarta
const lat = ref(-6.200000)
const location = ref('')
const searchQuery = ref('')

// Keep post.location, post.longitude, post.latitude in sync with map values
watch([location, lng, lat], () => {
    post.location = location.value;
    post.longitude = lng.value;
    post.latitude = lat.value;
});

onMounted(() => {
    // get the user's current position using GPS
    if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(
            (position) => {
                lng.value = position.coords.longitude;
                lat.value = position.coords.latitude;

                setupMap(); // Initialize the map at user's location
            },
            (error) => {
                console.warn('Geolocation failed or permission denied:', error.message);
                setupMap(); // Fallback to default Jakarta
            }
        );
    } else {
        console.warn("Geolocation is not supported by this browser.");
        setupMap(); // Fallback
    }
});

// Function to set up the Mapbox map and marker
const setupMap = () => {
    map.value = new mapboxgl.Map({
        container: mapContainer.value,
        style: 'mapbox://styles/mapbox/streets-v11',
        center: [lng.value, lat.value],
        zoom: 12
    });

    marker.value = new mapboxgl.Marker({ draggable: true })
        .setLngLat([lng.value, lat.value])
        .addTo(map.value);

    marker.value.on('dragend', () => {
        const { lng: newLng, lat: newLat } = marker.value.getLngLat();
        lng.value = newLng;
        lat.value = newLat;
        reverseGeocode();
    });

    reverseGeocode(); // Initial reverse geocode
}

const reverseGeocode = async () => {
    const res = await axios.get(
        `https://api.mapbox.com/geocoding/v5/mapbox.places/${lng.value},${lat.value}.json`,
        {
            params: {
                access_token: mapboxgl.accessToken
            }
        }
    )
    if (res.data?.features?.length > 0) {
        location.value = res.data.features[0].place_name
    }
}

const searchLocation = async () => {
    const res = await axios.get(
        `https://api.mapbox.com/geocoding/v5/mapbox.places/${encodeURIComponent(searchQuery.value)}.json`,
        {
            params: {
                access_token: mapboxgl.accessToken,
                limit: 1
            }
        }
    )
    if (res.data?.features?.length > 0) {
        const feature = res.data.features[0]
        lng.value = feature.center[0]
        lat.value = feature.center[1]
        location.value = feature.place_name
        map.value.flyTo({ center: [lng.value, lat.value], zoom: 14 })
        marker.value.setLngLat([lng.value, lat.value])
    }
}

// Submit function for storing service
const store = async () => {
    // Ensure post.location, longitude, latitude are up to date
    post.location = location.value;
    post.longitude = lng.value;
    post.latitude = lat.value;

    const formData = new FormData();
    formData.append("title", post.title);
    formData.append("description", post.description);
    formData.append("location", post.location);
    formData.append("longitude", post.longitude);
    formData.append("latitude", post.latitude);
    formData.append("end_date", post.end_date);

    // Append the image file with its name
    if (post.image) {
        formData.append("image", post.image, post.image.name);
    }

    // Append array fields
    post.option.forEach((opt, i) => {
        formData.append(`option[${i}]`, opt);
    });

    post.time.forEach((t, i) => {
        formData.append(`time[${i}]`, t);
    });

    post.days.forEach((day, i) => {
        formData.append(`days[${i}]`, day);
    });

    const { success, validationErrors, message } = await servicesStore.createService(formData);

    if (success) {
        servicesStore.showNotification("Service created successfully.", "success");
        router.push({ path: "/service" });
    } else {
        validation.value = validationErrors || {};
        if (message) {
            servicesStore.showNotification(message, "error");
        } else {
            servicesStore.showNotification("Failed to create service.", "error");
        }
    }
};
</script>

<template>
    <DefaultLayout class="bg-whiteBgPrimary-100">
        <div class="max-h-fit md:p-9 p-4 flex flex-col gap-6 bg-white rounded-2xl">
            <div class="flex flex-col gap-1">
                <!-- Notifikasi -->
                <AlertStatus :message="servicesStore.notification.message" :type="servicesStore.notification.type"
                    :is-visible="servicesStore.notification.show" @close="servicesStore.notification.show = false" />
                <h2 class="text-codgray-900 md:text-2xl text-base font-semibold">
                    Create Service
                </h2>
            </div>
            <form @submit.prevent="store" class="flex flex-col gap-6">
                <!-- Title -->
                <div class="flex flex-col gap-2">
                    <label class="text-sm md:text-base text-wildsand-600 flex gap-1" for="title">Title
                        <span class="text-red-600">*</span>
                    </label>
                    <input
                        class="w-full hover:border-cobalt-700 h-12 border border-wildsand-300 hover:bg-cobalt-50 focus:outline-none focus:ring-1 focus:ring-cobalt-700 text-codgray-900 rounded-md shadow-sm p-2 text-base placeholder-small"
                        id="title" placeholder="Enter service title" type="text" v-model="post.title" />
                    <!-- validation -->
                    <div class="mt-2 text-red-600" v-if="validation.title">
                        {{ validation.title[0] }}
                    </div>
                </div>

                <!-- Image -->
                <div class="flex flex-col gap-2">
                    <label class="text-sm md:text-base text-wildsand-600 flex gap-1" for="image">Image
                        <span class="text-red-600">*</span>
                    </label>
                    <input type="file" id="image" @change="(e) => {
                        post.image = e.target.files[0];
                        console.log('Selected file:', post.image);
                    }" />
                    <!-- validation -->
                    <div class="mt-2 text-red-600" v-if="validation.image">
                        {{ validation.image[0] }}
                    </div>
                </div>

                <!-- Description -->
                <div class="flex flex-col gap-2">
                    <label class="text-sm md:text-base text-wildsand-600 flex gap-1" for="description">Description
                        <span class="text-red-600">*</span>
                    </label>
                    <textarea
                        class="w-full hover:border-cobalt-700 h-24 border border-wildsand-300 hover:bg-cobalt-50 focus:outline-none focus:ring-1 focus:ring-cobalt-700 text-codgray-900 rounded-md shadow-sm p-2 text-base placeholder-small"
                        id="description" placeholder="Enter service description" v-model="post.description"></textarea>
                    <!-- validation -->
                    <div class="mt-2 text-red-600" v-if="validation.description">
                        {{ validation.description[0] }}
                    </div>
                </div>

                <!-- Location -->
                <div class="flex flex-col gap-2">
                    <label class="text-sm md:text-base text-wildsand-600 flex gap-1" for="location">Location
                        <span class="text-red-600">*</span>
                    </label>
                    <div class="space-y-4">
                        <div class="flex gap-2">
                            <input v-model="searchQuery" type="text" class="w-full border p-2 rounded"
                                placeholder="Find Location..." @keyup.enter="searchLocation" />
                            <button type="button" @click="searchLocation"
                                class="px-4 py-2 w-full px-4 max-w-fit font-semibold py-2 bg-gradient-to-b from-cobalt-700 to-cobalt-900 text-white rounded-xl w-36">
                                Search
                            </button>
                        </div>
                        <div ref="mapContainer" class="w-full h-[400px] rounded shadow" />
                        <div class="text-sm">
                            <p><strong>Location:</strong> {{ location }}</p>
                            <p><strong>Longitude:</strong> {{ lng }}</p>
                            <p><strong>Latitude:</strong> {{ lat }}</p>
                        </div>
                    </div>
                    <!-- validation -->
                    <div class="mt-2 text-red-600" v-if="validation.location">
                        {{ validation.location[0] }}
                    </div>
                </div>

                <!-- Option (Multiple Input) -->
                <div class="flex flex-col gap-2">
                    <label class="text-sm md:text-base text-wildsand-600 flex gap-1" for="option">Option
                        <span class="text-red-600">*</span>
                    </label>
                    <div class="grid grid-cols-3 gap-2">
                        <label><input type="checkbox" value="Offline" v-model="post.option" /> Offline</label>
                        <label><input type="checkbox" value="Online" v-model="post.option" /> Online</label>
                    </div>
                    <!-- validation -->
                    <div class="mt-2 text-red-600" v-if="validation.option">
                        {{ validation.option[0] }}
                    </div>
                </div>

                <!-- Time (Multiple Input) -->
                <div class="flex flex-col gap-2">
                    <label class="text-sm md:text-base text-wildsand-600 flex gap-1" for="time">Time
                        <span class="text-red-600">*</span>
                    </label>

                    <!-- Range input for generating times -->
                    <div class="flex items-center gap-2 mt-2">
                        <input
                            class="w-full hover:border-cobalt-700 h-12 border border-wildsand-300 hover:bg-cobalt-50 focus:outline-none focus:ring-1 focus:ring-cobalt-700 text-codgray-900 rounded-md shadow-sm p-2 text-base placeholder-small"
                            type="time" v-model="rangeStart" placeholder="Start time" />
                        <span>-</span>
                        <input
                            class="w-full hover:border-cobalt-700 h-12 border border-wildsand-300 hover:bg-cobalt-50 focus:outline-none focus:ring-1 focus:ring-cobalt-700 text-codgray-900 rounded-md shadow-sm p-2 text-base placeholder-small"
                            type="time" v-model="rangeEnd" placeholder="End time" />
                        <button type="button" @click="generateTimes"
                            class="w-full px-4 max-w-fit font-semibold py-2 bg-gradient-to-b from-cobalt-700 to-cobalt-900 text-white rounded-xl w-36">
                            Generate per 1 hour
                        </button>
                    </div>

                    <div v-for="(t, index) in post.time" :key="index" class="flex items-center gap-2">
                        <input
                            class="w-full hover:border-cobalt-700 h-12 border border-wildsand-300 hover:bg-cobalt-50 focus:outline-none focus:ring-1 focus:ring-cobalt-700 text-codgray-900 rounded-md shadow-sm p-2 text-base placeholder-small"
                            type="time" v-model="post.time[index]" :id="'time-' + index"
                            placeholder="Enter service time" />
                        <!-- Remove button -->
                        <button type="button" @click="post.time.splice(index, 1)"
                            class="text-red-500 hover:text-red-700" v-if="post.time.length > 1">
                            &times;
                        </button>
                    </div>

                    <!-- Add more time button -->
                    <button type="button" @click="post.time.push('')"
                        class="text-sm text-cobalt-700 hover:underline w-fit mt-1">
                        + Add more time
                    </button>

                    <!-- validation -->
                    <div class="mt-2 text-red-600" v-if="validation.time">
                        {{ validation.time[0] }}
                    </div>
                </div>


                <!-- Days (Multiple Checkboxes) -->
                <div class="flex flex-col gap-2">
                    <label class="text-sm md:text-base text-wildsand-600 flex gap-1">Days
                    </label>
                    <div class="grid grid-cols-3 gap-2">
                        <label><input type="checkbox" value="Monday" v-model="post.days" /> Monday</label>
                        <label><input type="checkbox" value="Tuesday" v-model="post.days" /> Tuesday</label>
                        <label><input type="checkbox" value="Wednesday" v-model="post.days" /> Wednesday</label>
                        <label><input type="checkbox" value="Thursday" v-model="post.days" /> Thursday</label>
                        <label><input type="checkbox" value="Friday" v-model="post.days" /> Friday</label>
                        <label><input type="checkbox" value="Saturday" v-model="post.days" /> Saturday</label>
                        <label><input type="checkbox" value="Sunday" v-model="post.days" /> Sunday</label>
                    </div>
                    <div v-if="validation.days" class="mt-2 text-red-600">
                        {{ validation.days[0] }}
                    </div>
                </div>

                <!-- End Date -->
                <div class="flex flex-col gap-2">
                    <label class="text-sm md:text-base text-wildsand-600 flex gap-1" for="end_date">End Date
                        <span class="text-red-600">*</span>
                    </label>
                    <input
                        class="w-full hover:border-cobalt-700 h-12 border border-wildsand-300 hover:bg-cobalt-50 focus:outline-none focus:ring-1 focus:ring-cobalt-700 text-codgray-900 rounded-md shadow-sm p-2 text-base placeholder-small"
                        id="end_date" type="date" v-model="post.end_date" />
                    <!-- validation -->
                    <div class="mt-2 text-red-600" v-if="validation.end_date">
                        {{ validation.end_date[0] }}
                    </div>
                </div>

                <div class="justify-end flex w-full gap-4">
                    <!-- Cancel Button -->
                    <button type="button"
                        class="md:px-6 md:py-3 px-4 max-w-fit font-semibold py-2 bg-gray-200 text-gray-700 rounded-xl w-36 hover:bg-gray-300"
                        @click="cancel">
                        Cancel
                    </button>
                    <!-- Submit Button -->
                    <button type="submit"
                        class="md:px-6 md:py-3 px-4 max-w-fit font-semibold py-2 bg-gradient-to-b from-cobalt-700 to-cobalt-900 text-white rounded-xl w-36">
                        Create Service
                    </button>
                </div>

                <!-- Notification -->
                <div v-if="notification" class="mt-4 p-4 bg-green-100 text-green-700 rounded">
                    {{ notification }}
                </div>
            </form>
        </div>
    </DefaultLayout>
</template>
<style>
@import "mapbox-gl/dist/mapbox-gl.css";
</style>
