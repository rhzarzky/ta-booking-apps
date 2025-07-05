//MapModal.vue

<script setup>
import { ref, watch, nextTick } from 'vue';
import mapboxgl from 'mapbox-gl';
// Import icons dari Lucide-Vue-Next jika digunakan di komponen ini
import { MapPin, Bolt, Clock } from 'lucide-vue-next';

// Pastikan Anda telah mengatur variabel lingkungan VITE_MAPBOX_ACCESS_TOKEN
mapboxgl.accessToken = import.meta.env.VITE_MAPBOX_ACCESS_TOKEN;

const props = defineProps({
  isVisible: {
    type: Boolean,
    default: false
  },
  locationName: { // Alamat lengkap
    type: String,
    default: 'Lokasi Tidak Diketahui'
  },
  coordinates: { // [longitude, latitude] dari lokasi layanan (tujuan)
    type: Array,
    required: true
  },
  userCoordinates: { // [longitude, latitude] dari lokasi pengguna (asal)
    type: Array,
    default: () => [] // Default kosong jika lokasi user tidak ada
  },
  serviceTitle: { // Nama layanan untuk popup marker
    type: String,
    default: 'Lokasi Layanan'
  },
  distance: { // Jarak dalam km, misal: "3.56"
    type: [Number, String],
    default: null
  },
  duration: { // Durasi dalam menit, misal: "9"
    type: [Number, String],
    default: null
  },
  routeGeoJSON: { // Data GeoJSON dari rute yang sudah dihitung
    type: Object,
    default: null
  }
});

const emit = defineEmits(['close']);

const modalMapContainer = ref(null);
const modalMapInstance = ref(null);

watch(() => props.isVisible, async (newVal) => {
  if (newVal) {
    await nextTick(); // Tunggu sampai DOM dirender
    initializeModalMap();
  } else {
    // Membersihkan instance peta saat modal ditutup
    if (modalMapInstance.value) {
      modalMapInstance.value.remove();
      modalMapInstance.value = null;
    }
  }
}, { immediate: false });

const initializeModalMap = () => {
  if (!modalMapContainer.value || !props.coordinates || props.coordinates.length < 2) {
    console.error("Map container or service coordinates are missing for MapModal.");
    return;
  }

  const serviceCoords = props.coordinates;
  const userCoords = props.userCoordinates;

  if (modalMapInstance.value) modalMapInstance.value.remove();

  modalMapInstance.value = new mapboxgl.Map({
    container: modalMapContainer.value,
    style: 'mapbox://styles/mapbox/streets-v12',
    center: serviceCoords, // Default center ke lokasi layanan
    zoom: 14,
    preserveDrawingBuffer: true // Penting untuk menangani repaint yang benar dalam modal
  });

  // Tambahkan marker untuk lokasi layanan (biru)
  new mapboxgl.Marker({ color: '#3b82f6' }) // Warna biru
    .setLngLat(serviceCoords)
    .setPopup(new mapboxgl.Popup().setHTML(`<h6>${props.serviceTitle}</h6><p>${props.locationName}</p>`))
    .addTo(modalMapInstance.value);

  // Tambahkan marker untuk lokasi pengguna (oranye) jika ada
  if (userCoords && userCoords.length === 2) {
    new mapboxgl.Marker({ color: '#F97316' }) // Warna oranye
      .setLngLat(userCoords)
      .setPopup(new mapboxgl.Popup().setHTML('<h6>Lokasi Anda</h6>'))
      .addTo(modalMapInstance.value);
  }

  // Tambahkan kontrol navigasi (zoom in/out)
  modalMapInstance.value.addControl(new mapboxgl.NavigationControl(), 'top-right');

  modalMapInstance.value.on('load', () => {
    if (props.routeGeoJSON) {
      drawRoute(props.routeGeoJSON);
    }
    
    // Fit bounds untuk menampilkan kedua marker jika rute ada
    if (userCoords && userCoords.length === 2 && props.routeGeoJSON) {
        const bounds = new mapboxgl.LngLatBounds();
        bounds.extend(userCoords);
        bounds.extend(serviceCoords);
        modalMapInstance.value.fitBounds(bounds, { padding: 80, duration: 0 }); // padding agar tidak terlalu mepet
    } else {
        // Jika hanya ada satu marker, cukup set center dan zoom
        modalMapInstance.value.setCenter(serviceCoords);
        modalMapInstance.value.setZoom(14);
    }
  });

  // Jika peta sudah dimuat saat ini (misalnya, jika isVisible berubah setelah komponen mounted)
  if (modalMapInstance.value.isStyleLoaded() && props.routeGeoJSON) {
    drawRoute(props.routeGeoJSON);
  }
};

const drawRoute = (geojson) => {
  if (modalMapInstance.value.getSource('route-modal')) {
    modalMapInstance.value.getSource('route-modal').setData(geojson);
  } else {
    modalMapInstance.value.addSource('route-modal', { type: 'geojson', data: geojson });
    modalMapInstance.value.addLayer({
      id: 'route-modal',
      type: 'line',
      source: 'route-modal',
      layout: { 'line-join': 'round', 'line-cap': 'round' },
      paint: { 'line-color': '#2563eb', 'line-width': 6, 'line-opacity': 0.8 },
    });
  }
};

const closeModal = () => {
  emit('close');
};
</script>

<template>
  <div v-if="isVisible" class="fixed inset-0 z-[100] flex items-center justify-center p-4 bg-black bg-opacity-60">
    <div class="bg-white rounded-lg shadow-xl w-full max-w-lg overflow-hidden animate-fade-in-up">
      <div class="flex flex-col p-4">
        <div class="flex items-start gap-2 mb-3 text-gray-700">
          <MapPin class="w-5 h-5 text-indigo-600 mt-1 flex-shrink-0" />
          <span class="text-base font-semibold">{{ locationName }}</span>
        </div>

        <div v-if="distance && duration" class="mb-4 p-3 bg-blue-50 rounded-lg text-blue-800 flex flex-wrap items-center gap-x-6 gap-y-2 text-sm font-medium">
          <div class="flex items-center">
            <Bolt class="w-4 h-4 mr-2 opacity-80" />
            Jarak: <strong class="ml-1.5">{{ distance }} km</strong>
          </div>
          <div class="flex items-center">
            <Clock class="w-4 h-4 mr-2 opacity-80" />
            Estimasi: <strong class="ml-1.5">{{ duration }} menit</strong>
          </div>
        </div>

        <div ref="modalMapContainer" class="w-full h-80 rounded-lg border border-gray-200 relative overflow-hidden">
          <div class="absolute bottom-1 left-1 bg-white bg-opacity-75 text-xs text-gray-600 p-1 rounded-sm z-10">
              © Mapbox © OpenStreetMap <a href="https://www.mapbox.com/feedback/#/map/publisher_data" target="_blank" rel="noopener noreferrer" class="underline hover:text-blue-600">Improve this map</a>
          </div>
        </div>
      </div>
      
      <div class="p-4 border-t border-gray-200 text-right">
        <button @click="closeModal" class="px-5 py-1.5 rounded-lg text-gray-700 bg-gray-100 hover:bg-gray-200 transition-colors duration-200 font-semibold text-sm">
          Tutup
        </button>
      </div>
    </div>
  </div>
</template>

<style>
/* Penting: Impor stylesheet Mapbox di komponen ini */
@import 'mapbox-gl/dist/mapbox-gl.css';

/* Animasi sederhana untuk modal */
.animate-fade-in-up {
  animation: fadeInScaleUp 0.3s ease-out forwards;
}

@keyframes fadeInScaleUp {
  from {
    opacity: 0;
    transform: scale(0.95) translateY(10px);
  }
  to {
    opacity: 1;
    transform: scale(1) translateY(0);
  }
}

/* Kustomisasi Popup Mapbox agar lebih sesuai dengan tema */
.mapboxgl-popup-content {
  padding: 10px 15px !important;
  font-family: 'Inter', sans-serif, system-ui !important;
  border-radius: 8px !important;
  box-shadow: 0 4px 12px rgba(0,0,0,0.1) !important;
  border: none !important;
}

.mapboxgl-popup-content h6 {
  font-weight: 600;
  margin: 0;
  color: #1e293b; /* slate-800 */
}

.mapboxgl-popup-content p {
  font-size: 0.875rem;
  color: #4a5568; /* gray-700 */
  margin-top: 5px;
}

.mapboxgl-popup-close-button {
  font-size: 1.2rem;
  padding: 2px 6px;
  color: #64748b; /* slate-500 */
}
</style>