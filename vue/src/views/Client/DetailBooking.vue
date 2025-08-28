<script setup>
import { ref, onMounted, computed, nextTick } from 'vue';
import { useRoute } from 'vue-router';
import { useBookingStore } from '@/stores/booking';
import mapboxgl from 'mapbox-gl';

mapboxgl.accessToken = import.meta.env.VITE_MAPBOX_ACCESS_TOKEN;

const route = useRoute();
const bookingStore = useBookingStore();

const mapContainer = ref(null);
const mapInstance = ref(null);
const userLocation = ref(null);
const distance = ref(null);
const duration = ref(null);

const bookingDetail = computed(() => bookingStore.bookingDetail);
const loading = computed(() => bookingStore.loading);
const error = computed(() => bookingStore.error);

onMounted(async () => {
  const bookingId = route.params.id;
  await bookingStore.fetchBookingDetail(bookingId);

  // Pastikan bookingDetail tersedia dan bukan booking online sebelum setup map
  if (bookingDetail.value && !isOnlineBooking.value) {
    await setupMapAndNavigation();
  }
});

const setupMapAndNavigation = async () => {
  try {
    const userCoords = await getUserLocation();
    userLocation.value = userCoords;

    // Pastikan DOM sudah diperbarui sebelum menginisialisasi peta
    await nextTick();

    const destinationCoords = [
      bookingDetail.value.service.longitude,
      bookingDetail.value.service.latitude
    ];

    initializeMap(destinationCoords);
    getDirections(userCoords, destinationCoords);
  } catch (err) {
    console.error("Gagal setup peta:", err);
  }
};

const getUserLocation = () => {
  return new Promise((resolve, reject) => {
    if (!navigator.geolocation) {
      return reject(new Error('Geolocation tidak didukung oleh browser ini.'));
    }
    navigator.geolocation.getCurrentPosition(
      (position) => resolve([position.coords.longitude, position.coords.latitude]),
      (err) => reject(err),
      { enableHighAccuracy: true, timeout: 10000, maximumAge: 0 }
    );
  });
};

const initializeMap = (centerCoords) => {
  if (!mapContainer.value || !Array.isArray(centerCoords) || centerCoords.length < 2) return;
  if (mapInstance.value) mapInstance.value.remove(); // Hapus instance map yang lama jika ada

  mapInstance.value = new mapboxgl.Map({
    container: mapContainer.value,
    style: 'mapbox://styles/mapbox/streets-v12',
    center: centerCoords,
    zoom: 14,
  });

  new mapboxgl.Marker({ color: '#3b82f6' }) // Warna biru
    .setLngLat(centerCoords)
    .setPopup(new mapboxgl.Popup().setHTML(`<h6>${bookingDetail.value.service.title}</h6>`))
    .addTo(mapInstance.value);

  if (userLocation.value) {
    new mapboxgl.Marker({ color: '#F97316' }) // Warna oranye untuk lokasi user
      .setLngLat(userLocation.value)
      .setPopup(new mapboxgl.Popup().setHTML('<h6>Lokasi Anda</h6>'))
      .addTo(mapInstance.value);
  }

  mapInstance.value.addControl(new mapboxgl.NavigationControl(), 'top-right');
};

const getDirections = async (startCoords, endCoords) => {
  try {
    const response = await fetch(`https://api.mapbox.com/directions/v5/mapbox/driving/${startCoords.join(',')};${endCoords.join(',')}?steps=true&geometries=geojson&access_token=${mapboxgl.accessToken}`);
    const data = await response.json();

    if (data.routes && data.routes.length > 0) {
      const route = data.routes[0];
      distance.value = (route.distance / 1000).toFixed(2); // Dalam kilometer
      duration.value = Math.round(route.duration / 60); // Dalam menit

      const routeGeoJSON = { type: 'Feature', geometry: route.geometry };

      // Pastikan peta sudah dimuat sebelum menambahkan rute
      mapInstance.value.on('load', () => drawRoute(routeGeoJSON));
      // Jika peta sudah dimuat saat ini
      if (mapInstance.value.isStyleLoaded()) drawRoute(routeGeoJSON);

      const bounds = new mapboxgl.LngLatBounds(startCoords, endCoords);
      mapInstance.value.fitBounds(bounds, { padding: 80 }); // Sesuaikan zoom agar kedua marker terlihat
    }
  } catch (err) {
    console.error("Gagal mendapatkan rute:", err);
  }
};

const drawRoute = (geojson) => {
  if (mapInstance.value.getSource('route')) {
    mapInstance.value.getSource('route').setData(geojson);
  } else {
    mapInstance.value.addSource('route', { type: 'geojson', data: geojson });
    mapInstance.value.addLayer({
      id: 'route',
      type: 'line',
      source: 'route',
      layout: { 'line-join': 'round', 'line-cap': 'round' },
      paint: { 'line-color': '#2563eb', 'line-width': 6, 'line-opacity': 0.8 },
    });
  }
};

// Computed Properties
const formattedDate = computed(() => {
    if (!bookingDetail.value?.service.date) return '';
    const date = new Date(bookingDetail.value.service.date + 'T00:00:00');
    // Pastikan untuk menggunakan 'id-ID' untuk format tanggal Indonesia
    return date.toLocaleDateString('id-ID', { day: 'numeric', month: 'long', year: 'numeric' });
});

const statusClass = computed(() => {
  const status = bookingDetail.value?.service.status?.toLowerCase();
  switch (status) {
    case 'approved': return 'bg-blue-100 text-blue-800 border border-blue-200';
    case 'pending': return 'bg-yellow-100 text-yellow-800 border border-yellow-200';
    case 'declined': return 'bg-red-100 text-red-800 border border-red-200';
    case 'completed': return 'bg-green-100 text-green-800 border border-green-200';
    default: return 'bg-slate-100 text-slate-800 border border-slate-200';
  }
});

const isOnlineBooking = computed(() => bookingDetail.value?.service.option === 'Online');
const showCalendarButton = computed(() => bookingDetail.value?.service.status === 'Approved');
const generateGoogleCalendarUrl = computed(() => {
    if (!showCalendarButton.value) return '#';
    const { title, description, location, date, time } = bookingDetail.value.service;
    const eventTitle = encodeURIComponent(title);
    const eventDesc = encodeURIComponent(description || '');
    const eventLoc = encodeURIComponent(isOnlineBooking.value ? 'Online Event' : location);

    const [hours, minutes] = time.split(':');
    const start = new Date(date);
    start.setHours(hours, minutes);
    const end = new Date(start.getTime() + 60 * 60 * 1000); // Durasi 1 jam
    const formatDateToUTC = d => d.toISOString().replace(/-|:|\.\d+/g, '');
    return `https://www.google.com/calendar/render?action=TEMPLATE&text=${eventTitle}&details=${eventDesc}&location=${eventLoc}&dates=${formatDateToUTC(start)}/${formatDateToUTC(end)}`;
});
</script>

<template>
  <div class="bg-slate-50 min-h-screen font-sans">
    <div class="max-w-5xl mx-auto p-5 sm:p-6 lg:p-8">
      <div v-if="loading" class="text-center text-slate-500 py-12">
        <p class="text-lg mb-4">Loading booking details...</p>
        <svg class="animate-spin h-10 w-10 text-blue-600 mx-auto" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
          <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" />
          <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z" />
        </svg>
      </div>

      <div v-else-if="error" class="text-center bg-red-100 border-l-4 border-red-500 text-red-700 p-6 rounded-r-lg shadow-md">
        <h3 class="font-bold text-xl mb-2">Error occurred</h3>
        <p>{{ error }}</p>
      </div>

      <div v-else-if="bookingDetail" class="bg-white rounded-2xl shadow-lg overflow-hidden transition-all duration-300">
        <div class="w-full h-60 md:h-80 bg-slate-200 relative">
          <img v-if="bookingDetail.service.image" :src="bookingDetail.service.image" :alt="bookingDetail.service.title" class="w-full h-full object-cover" />
          <div v-else class="w-full h-full flex items-center justify-center">
            <svg class="w-16 h-16 text-slate-400" fill="currentColor" viewBox="0 0 24 24"><path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-1 16H6v-4.58l2.29 2.29l3.54-3.53l4.58 4.58V19zM17 10c-1.1 0-2-.9-2-2s.9-2 2-2s2 .9 2 2s-.9 2-2 2z"/></svg>
          </div>
          <div class="absolute bottom-0 left-0 w-full h-20 bg-gradient-to-t from-black/50 to-transparent"></div>
        </div>

        <div class="p-6 sm:p-8 md:p-10">
          <div class="flex flex-col md:flex-row md:items-start md:justify-between gap-4 mb-3">
            <h1 class="text-3xl sm:text-4xl font-bold text-slate-800 leading-tight">{{ bookingDetail.service.title }}</h1>
            <span :class="['px-4 py-1.5 rounded-full text-sm font-semibold whitespace-nowrap shadow-sm', statusClass]">
              {{ bookingDetail.service.status }}
            </span>
          </div>

          <p class="text-slate-600 text-base sm:text-lg mb-10 border-l-4 border-slate-200 pl-4">
            {{ bookingDetail.service.description }}
          </p>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-10">
            <div class="info-card p-5 sm:p-6">
              <h3 class="info-card-title">Schedule</h3>
              <div class="info-card-content justify-between items-center"> <div class="flex items-center">
                  <svg class="w-6 h-6 text-blue-500 mr-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"></path></svg>
                  <p class="text-slate-800 font-medium text-base sm:text-lg">{{ formattedDate }}, {{ bookingDetail.service.time }} WIB</p>
                </div>
                <a v-if="showCalendarButton" :href="generateGoogleCalendarUrl" target="_blank" rel="noopener noreferrer" class="calendar-button-small">
                  <svg class="w-5 h-5 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" /></svg>
                  Save
                </a>
              </div>
            </div>
            <div class="info-card p-5 sm:p-6">
              <h3 class="info-card-title">Service Options</h3>
              <div class="info-card-content">
                    <svg class="w-6 h-6 text-blue-500 mr-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"></path></svg>
                <p class="text-slate-800 font-medium text-base sm:text-lg">{{ bookingDetail.service.option }}</p>
              </div>
            </div>
          </div>

          <div class="mb-10">
            <h3 class="text-2xl font-semibold text-slate-800 mb-4">Location</h3>
            <div class="bg-slate-50 border border-slate-200 p-5 rounded-lg shadow-sm">
              <template v-if="isOnlineBooking">
                <a :href="bookingDetail.service.location" target="_blank" rel="noopener noreferrer" class="online-link text-base sm:text-lg py-2 sm:py-3 px-4 sm:px-6">
                  <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"></path></svg>
                  Open Online Meeting Link
                </a>
              </template>

              <template v-else>
                <p class="text-slate-700 flex items-start mb-5 text-base">
                  <svg class="w-7 h-7 mr-4 text-blue-500 flex-shrink-0 mt-1" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a2 2 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0zM15 11a3 3 0 11-6 0 3 3 0 016 0z"></path></svg>
                  <span>{{ bookingDetail.service.location }}</span>
                </p>

                <div v-if="distance && duration" class="mb-5 p-3 sm:p-3.5 bg-blue-50 rounded-lg text-blue-800 flex flex-wrap items-center gap-x-6 gap-y-2 text-sm sm:text-base font-medium">
                  <div class="flex items-center"><svg class="w-5 h-5 mr-2 opacity-80" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"></path></svg>Jarak: <strong class="ml-1.5">{{ distance }} km</strong></div>
                  <div class="flex items-center"><svg class="w-5 h-5 mr-2 opacity-80" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>Estimasi: <strong class="ml-1.5">{{ duration }} menit</strong></div>
                </div>

                <div ref="mapContainer" class="mapbox-map-container h-72 sm:h-80 md:h-96 lg:h-[450px] rounded-lg border border-slate-200"></div>

              </template>
            </div>
          </div>

          <div v-if="bookingDetail.service.status === 'Declined'" class="mb-6">
              <h3 class="text-2xl font-semibold text-slate-800 mb-4">Note</h3>
              <div class="bg-slate-50 border border-slate-200 p-5 rounded-lg shadow-sm">
                  <p class="text-slate-600 italic leading-relaxed text-base">{{ bookingDetail.service.note || 'Tidak ada catatan tambahan yang diberikan.' }}</p>
              </div>
          </div>
          </div>
      </div>
    </div>
  </div>
</template>

<style>
/* Penting: Impor stylesheet Mapbox */
@import 'mapbox-gl/dist/mapbox-gl.css';

/* Hapus height tetap di sini, gunakan kelas Tailwind di template */
.mapbox-map-container {
  width: 100%;
}

.info-card {
  /* Class @apply ini akan mengambil p-5 yang sudah ada, lalu di template ditambahkan sm:p-6 */
  @apply bg-white border border-slate-200 rounded-xl shadow-sm hover:shadow-md transition-shadow duration-300;
}

.info-card-title {
  @apply text-sm font-semibold text-slate-500 mb-2 uppercase tracking-wider;
}

.info-card-content {
  /* text-lg untuk ukuran default yang lebih besar */
  @apply flex items-center text-lg;
}

.online-link {
  /* Penyesuaian padding dan font size untuk mobile */
  @apply inline-flex items-center font-semibold text-blue-600 bg-blue-50 hover:bg-blue-100 px-4 py-2.5 sm:px-6 sm:py-3 rounded-lg transition-colors duration-300 text-base sm:text-lg;
}

/* Old calendar-button styles (can be removed if not used elsewhere) */
/* .calendar-button {
  @apply bg-blue-600 hover:bg-blue-700 text-white font-semibold px-6 py-2.5 sm:px-8 sm:py-3 rounded-full shadow-lg hover:shadow-xl transition-all transform hover:scale-105 duration-300 inline-flex items-center text-base sm:text-lg;
} */

/* New style for the smaller calendar button inside info-card */
.calendar-button-small {
  @apply inline-flex items-center justify-center font-semibold text-blue-600 bg-blue-100 hover:bg-blue-200 px-3 py-1.5 rounded-full text-sm transition-colors duration-300 whitespace-nowrap;
  /* Add responsive adjustments if needed */
  @screen sm {
    padding: 0.5rem 1rem; /* px-4 py-2 */
    font-size: 0.875rem; /* text-sm */
  }
}


/* Kustomisasi Popup Mapbox agar lebih sesuai dengan tema */
.mapboxgl-popup-content {
  padding: 10px 15px !important;
  font-family: 'Inter', sans-serif, system-ui !important; /* Ganti dengan font proyek Anda jika ada */
  border-radius: 8px !important;
  box-shadow: 0 4px 12px rgba(0,0,0,0.1) !important;
  border: none !important;
}

.mapboxgl-popup-content h6 {
  font-weight: 600;
  margin: 0;
  color: #1e293b; /* slate-800 */
}

.mapboxgl-popup-close-button {
  font-size: 1.2rem;
  padding: 2px 6px;
  color: #64748b; /* slate-500 */
}
</style>