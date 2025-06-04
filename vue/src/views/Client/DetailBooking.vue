<script setup>
import { onMounted, ref, computed, nextTick } from 'vue'
import { useRoute } from 'vue-router'
import { bookingApi } from '@/api/booking-api'
import mapboxgl from 'mapbox-gl'
import 'mapbox-gl/dist/mapbox-gl.css' // Pastikan ini diimpor juga di script setup atau di bagian style global

// Konfigurasi Mapbox Access Token Anda
mapboxgl.accessToken = import.meta.env.VITE_MAPBOX_ACCESS_TOKEN;

const route = useRoute()
const booking = ref(null)
const mapContainer = ref(null) // Ref untuk elemen DOM peta
const map = ref(null) // Ref untuk instance peta Mapbox

// Variabel baru untuk lokasi pengguna dan informasi navigasi
const userLocation = ref(null) // [longitude, latitude] pengguna
const distance = ref(null) // Jarak dalam kilometer
const duration = ref(null) // Durasi dalam menit

const userLocationMarker = ref(null); // Ref untuk marker lokasi pengguna

// Fetch data saat komponen dimount
onMounted(async () => {
  try {
    const response = await bookingApi.getBookingDetail(route.params.id)
    booking.value = response

    // Panggil fungsi untuk mendapatkan lokasi pengguna
    await getUserLocation();

    // Setelah data booking tersedia dan jika bukan online booking, inisialisasi peta
    if (booking.value && !isOnlineBooking.value) {
      await nextTick(); // Pastikan DOM sudah dirender sebelum inisialisasi peta
      initializeMap(booking.value.service.location);
    }
  } catch (err) {
    console.error('Gagal mengambil detail booking:', err)
  }
})

// Fungsi untuk mendapatkan lokasi pengguna
const getUserLocation = async () => {
  if (navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(
      (position) => {
        userLocation.value = [position.coords.longitude, position.coords.latitude];
        console.log('Lokasi Pengguna:', userLocation.value);

        // Jika peta sudah ada dan marker lokasi pengguna belum ada, tambahkan
        if (map.value && !userLocationMarker.value) {
          userLocationMarker.value = new mapboxgl.Marker({ color: '#FF5733' }) // Warna berbeda untuk user
            .setLngLat(userLocation.value)
            .setPopup(new mapboxgl.Popup().setHTML("<h4>Lokasi Anda Saat Ini</h4>")) // Popup
            .addTo(map.value);
        } else if (userLocationMarker.value) {
          // Jika marker sudah ada, update posisinya
          userLocationMarker.value.setLngLat(userLocation.value);
        }

        // Jika booking sudah ada dan bukan online, panggil fungsi navigasi
        if (booking.value && !isOnlineBooking.value && userLocation.value && booking.value.service.location) {
          getDirections();
        }
      },
      (error) => {
        console.error('Gagal mendapatkan lokasi pengguna:', error);
        alert('Gagal mendapatkan lokasi Anda. Pastikan Anda mengizinkan akses lokasi.');
      },
      {
        enableHighAccuracy: true,
        timeout: 5000,
        maximumAge: 0
      }
    );
  } else {
    console.warn('Geolocation tidak didukung oleh browser ini.');
    alert('Browser Anda tidak mendukung fitur lokasi.');
  }
}

// Fungsi untuk mendapatkan rute navigasi, jarak, dan durasi
const getDirections = async () => {
  if (!userLocation.value || !booking.value?.service.location) {
    console.warn('Lokasi pengguna atau lokasi tujuan tidak tersedia untuk navigasi.');
    return;
  }

  try {
    // Geocoding lokasi tujuan untuk mendapatkan koordinat
    const destinationResponse = await fetch(`https://api.mapbox.com/geocoding/v5/mapbox.places/${encodeURIComponent(booking.value.service.location)}.json?access_token=${mapboxgl.accessToken}`);
    const destinationData = await destinationResponse.json();

    if (destinationData.features && destinationData.features.length > 0) {
      const destinationCoordinates = destinationData.features[0].center; // [longitude, latitude] tujuan

      // Memanggil Mapbox Directions API
      const directionsResponse = await fetch(
        `https://api.mapbox.com/directions/v5/mapbox/driving/${userLocation.value[0]},${userLocation.value[1]};${destinationCoordinates[0]},${destinationCoordinates[1]}?steps=true&geometries=geojson&access_token=${mapboxgl.accessToken}`
      );
      const directionsData = await directionsResponse.json();

      if (directionsData.routes && directionsData.routes.length > 0) {
        const route = directionsData.routes[0];
        distance.value = (route.distance / 1000).toFixed(2); // Konversi meter ke kilometer
        duration.value = (route.duration / 60).toFixed(0); // Konversi detik ke menit

        // Tambahkan rute ke peta
        if (map.value) {
          const geojson = {
            type: 'Feature',
            properties: {},
            geometry: route.geometry
          };

          if (map.value.getSource('route')) {
            map.value.getSource('route').setData(geojson);
          } else {
            map.value.addSource('route', {
              type: 'geojson',
              data: geojson
            });

            map.value.addLayer({
              id: 'route',
              type: 'line',
              source: 'route',
              layout: {
                'line-join': 'round',
                'line-cap': 'round'
              },
              paint: {
                'line-color': '#3887be',
                'line-width': 5,
                'line-opacity': 0.75
              }
            });
          }

          // Sesuaikan tampilan peta agar mencakup kedua lokasi dan rute
          const bounds = new mapboxgl.LngLatBounds();
          bounds.extend(userLocation.value);
          bounds.extend(destinationCoordinates);
          map.value.fitBounds(bounds, { padding: 50 }); // Padding agar tidak terlalu mepet
        }
      }
    }
  } catch (error) {
    console.error('Error saat mendapatkan rute navigasi:', error);
  }
}

// Fungsi untuk membuka navigasi di aplikasi Mapbox
const openNavigationInMapbox = async () => {
  if (!userLocation.value || !booking.value?.service.location) {
    alert('Lokasi Anda atau lokasi tujuan belum tersedia untuk navigasi.');
    return;
  }

  try {
    // Geocoding lokasi tujuan untuk mendapatkan koordinat yang akurat
    const destinationResponse = await fetch(`https://api.mapbox.com/geocoding/v5/mapbox.places/${encodeURIComponent(booking.value.service.location)}.json?access_token=${mapboxgl.accessToken}`);
    const destinationData = await destinationResponse.json();

    if (destinationData.features && destinationData.features.length > 0) {
      const destinationCoordinates = destinationData.features[0].center; // [longitude, latitude] tujuan

      // Buat URL Mapbox Navigation
      // Menggunakan koordinat tujuan untuk akurasi yang lebih baik
      const navigationUrl = `https://maps.mapbox.com/directions/?origin=${userLocation.value[0]},${userLocation.value[1]}&destination=${destinationCoordinates[0]},${destinationCoordinates[1]}&geometries=geojson&steps=true&overview=full&continue_straight=true&language=id&mode=driving`;

      // Buka URL di tab baru
      window.open(navigationUrl, '_blank');
    } else {
      alert('Gagal menemukan koordinat untuk lokasi tujuan.');
    }
  } catch (error) {
    console.error('Error saat menyiapkan navigasi:', error);
    alert('Terjadi kesalahan saat menyiapkan navigasi.');
  }
};


// Format tanggal menjadi
const formattedDate = computed(() => {
  if (!booking.value || !booking.value.service.date) return ''

  // Perbaikan: Tambahkan 'T00:00:00' untuk memastikan parsing sebagai waktu lokal
  // Ini menghindari masalah zona waktu yang menyebabkan tanggal mundur sehari
  const date = new Date(booking.value.service.date + 'T00:00:00');

  // Gunakan 'id-ID' untuk format tanggal bahasa Indonesia
  // Mengubah 'short' menjadi 'long' agar nama bulan penuh (misal: Juni, bukan Jun)
  return date.toLocaleDateString('id-ID', {
    day: 'numeric',
    month: 'long',
    year: 'numeric',
  })
})

// Class warna status
const statusClass = computed(() => {
  const status = (booking.value?.service.status || '').toLowerCase(); // Pastikan status diubah ke lowercase

  switch (status) {
    case 'approved':
      return 'bg-purple-100 text-purple-700';
    case 'pending':
      return 'bg-lime-100 text-lime-700';
    case 'declined': // Gunakan 'declined' (lowercase) agar sesuai dengan backend/activity card sebelumnya
      return 'bg-red-100 text-red-700';
    case 'completed': // Gunakan 'declined' (lowercase) agar sesuai dengan backend/activity card sebelumnya
      return 'bg-blue-100 text-blue-700';
    default:
      return 'bg-gray-100 text-gray-700';
  }
})

// Tampilkan tombol "Tambah ke Kalender" hanya jika status Approved
const showCalendarButton = computed(() => {
  return booking.value?.service.status === 'Approved'
})

// Deteksi jenis booking
const isOnlineBooking = computed(() => {
  return booking.value?.service.option === 'Online'
})

// Generate link Google Calendar
const generateGoogleCalendarUrl = computed(() => {
  if (!showCalendarButton.value || !booking.value) return '#'

  const { title, description, location, date, time } = booking.value.service
  const eventTitle = encodeURIComponent(title)
  const eventDesc = encodeURIComponent(description || '')
  const eventLoc = encodeURIComponent(location || 'Online/Offline Event')


  const start = new Date(`${date}T${time}`);
  const end = new Date(start.getTime() + 60 * 60 * 1000); // Asumsi durasi 1 jam


  const formatDateToUTCForGoogle = (d) => {
    const year = d.getUTCFullYear();
    const month = (d.getUTCMonth() + 1).toString().padStart(2, '0');
    const day = d.getUTCDate().toString().padStart(2, '0');
    const hours = d.getUTCHours().toString().padStart(2, '0');
    const minutes = d.getUTCMinutes().toString().padStart(2, '0');
    const seconds = d.getUTCSeconds().toString().padStart(2, '0');
    return `${year}${month}${day}T${hours}${minutes}${seconds}Z`; // 'Z' menandakan UTC
  };

  const eventTime = `${formatDateToUTCForGoogle(start)}/${formatDateToUTCForGoogle(end)}`;

  return `https://www.google.com/calendar/render?action=TEMPLATE&text=${eventTitle}&details=${eventDesc}&location=${eventLoc}&dates=${eventTime}`
})

// Fungsi untuk menginisialisasi peta
const initializeMap = async (address) => {
  if (!mapContainer.value) {
    console.error('Map container not found');
    return;
  }

  try {
    const response = await fetch(`https://api.mapbox.com/geocoding/v5/mapbox.places/${encodeURIComponent(address)}.json?access_token=${mapboxgl.accessToken}`);
    const data = await response.json();

    if (data.features && data.features.length > 0) {
      const coordinates = data.features[0].center; // [longitude, latitude]

      // Hancurkan peta yang ada jika ada (untuk mencegah inisialisasi ganda)
      if (map.value) {
        map.value.remove();
        map.value = null;
      }

      map.value = new mapboxgl.Map({
        container: mapContainer.value,
        style: 'mapbox://styles/mapbox/streets-v11', // Anda bisa ganti gaya peta
        center: coordinates,
        zoom: 15
      });

      // Tambahkan marker pada lokasi tujuan
      new mapboxgl.Marker()
        .setLngLat(coordinates)
        .setPopup(new mapboxgl.Popup().setHTML(`<h4>${booking.value.service.title}</h4><p>${booking.value.service.location}</p>`))
        .addTo(map.value);

      // Tambahkan kontrol navigasi
      map.value.addControl(new mapboxgl.NavigationControl(), 'top-right');

      // Setelah peta diinisialisasi, jika lokasi user sudah ada, tambahkan marker user
      if (userLocation.value) {
        userLocationMarker.value = new mapboxgl.Marker({ color: '#FF5733' }) // Warna berbeda untuk user
          .setLngLat(userLocation.value)
          .setPopup(new mapboxgl.Popup().setHTML("<h4>Lokasi Anda Saat Ini</h4>")) // Popup
          .addTo(map.value);

        // Langsung panggil getDirections jika peta sudah siap dan lokasi user tersedia
        getDirections();
      }
    } else {
      console.warn('Lokasi tujuan tidak ditemukan untuk alamat:', address);
      // Opsional: Tampilkan pesan ke pengguna bahwa lokasi tidak dapat ditampilkan
    }
  } catch (error) {
    console.error('Error saat melakukan geocoding atau inisialisasi peta:', error);
  }
}
</script>


<template>
  <div class="bg-gray-50 min-h-screen py-10 font-sans">
    <div v-if="booking" class="bg-white rounded-2xl shadow-xl overflow-hidden max-w-5xl mx-auto p-8 md:p-10">

      <div class="w-full h-64 bg-gray-200 flex items-center justify-center text-gray-400 overflow-hidden rounded-xl mb-8">
        <img v-if="booking.service.image" :src="booking.service.image" class="w-full h-full object-cover" />
        <svg v-else class="w-16 h-16 text-gray-300" fill="currentColor" viewBox="0 0 24 24">
          <path d="M4 3a2 2 0 00-2 2v14a2 2 0 002 2h16a2 2 0 002-2V5a2 2 0 00-2-2H4zm12 10l-4 4-6-6V5h10v8z" />
        </svg>
      </div>

      <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4 mb-6">
        <h2 class="text-3xl font-bold text-gray-800">{{ booking.service.title }}</h2>
        <span :class="['px-4 py-1 rounded-full text-sm font-medium', statusClass]">
          {{ booking.service.status }}
        </span>
      </div>

      <p class="text-gray-700 text-lg mb-8 leading-relaxed">
        {{ booking.service.description }}
      </p>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-8 mb-10">
        <div>
          <h3 class="text-xl font-semibold text-gray-700 mb-3">Schedule</h3>
          <div class="bg-blue-50 p-4 rounded-lg flex items-center shadow-sm">
            <svg class="w-5 h-5 text-blue-600 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
            </svg>
            <p class="text-gray-800 text-base">{{ formattedDate }},{{ booking.service.time }} WIB</p>
          </div>
        </div>

        <div>
          <h3 class="text-xl font-semibold text-gray-700 mb-3">Option</h3>
          <div class="bg-blue-50 p-4 rounded-lg flex items-center shadow-sm">
            <svg class="w-5 h-5 text-blue-600 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path d="M13 10V3L4 14h7v7l9-11h-7z" />
            </svg>
            <p class="text-gray-800 text-base">{{ booking.service.option }}</p>
          </div>
        </div>
      </div>

      <div class="mb-10">
        <h3 class="text-xl font-semibold text-gray-700 mb-3">Location</h3>
        <div class="bg-blue-50 p-4 rounded-lg shadow-sm">
          <template v-if="isOnlineBooking">
            <a :href="booking.service.location" target="_blank" class="text-blue-600 hover:underline flex items-center break-all">
              <svg class="w-5 h-5 mr-2 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" />
              </svg>
              {{ booking.service.location }}
            </a>
          </template>
          <template v-else>
            <p class="text-gray-800 flex items-center mb-2">
              <svg class="w-5 h-5 mr-2 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path d="M17.657 16.657L13.414 20.9a2 2 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                <path d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
              </svg>
              {{ booking.service.location }}
            </p>

            <div v-if="distance && duration" class="mt-4 p-3 bg-blue-100 rounded-md text-blue-800 flex items-center gap-2">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"></path></svg>
                <p>Jarak: <strong>{{ distance }} km</strong></p>
                <svg class="w-5 h-5 ml-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
                <p>Estimasi Waktu: <strong>{{ duration }} menit</strong></p>
            </div>

            <button v-if="userLocation && booking.value?.service.location" @click="openNavigationInMapbox" class="mt-4 bg-blue-600 hover:bg-blue-700 text-white font-semibold py-2 px-4 rounded-full shadow-md flex items-center justify-center gap-2">
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 20l-5.447-2.724A1 1 0 013 16.382V5.618a1 1 0 011.553-.894L9 4m7 16l-5.447-2.724A1 1 0 0110 16.382V5.618a1 1 0 011.553-.894L16 4m7 16l-5.447-2.724A1 1 0 0117 16.382V5.618a1 1 0 011.553-.894L23 4"></path></svg>
              Buka Navigasi di Mapbox
            </button>

            <div v-if="!isOnlineBooking" ref="mapContainer" class="mapbox-map-container rounded-md mt-4"></div>
          </template>
        </div>
      </div>

      <div class="mb-10">
        <h3 class="text-xl font-semibold text-gray-700 mb-3">Note</h3>
        <div class="bg-blue-50 p-4 rounded-lg shadow-sm">
          <p class="text-gray-800 italic">{{ booking.service.note || 'Tidak ada catatan tambahan.' }}</p>
        </div>
      </div>

      <div v-if="showCalendarButton" class="text-center mt-10">
        <a :href="generateGoogleCalendarUrl" target="_blank" class="bg-blue-600 hover:bg-blue-700 text-white font-semibold px-8 py-3 rounded-full shadow-lg transition transform hover:scale-105 inline-flex items-center">
          <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
          </svg>
          Add to Google Calendar
        </a>
      </div>
    </div>

    <div v-else class="text-center text-gray-500 py-12">
      <p class="text-lg">Loading booking details...</p>
      <svg class="animate-spin h-8 w-8 text-blue-500 mx-auto mt-4" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" />
        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z" />
      </svg>
    </div>
  </div>
</template>

<style>
/* Penting: Impor stylesheet Mapbox */
@import 'mapbox-gl/dist/mapbox-gl.css';

/* Atur tinggi dan margin untuk container peta */
.mapbox-map-container {
  height: 400px; /* Sesuaikan tinggi sesuai kebutuhan Anda */
  width: 100%;
  margin-top: 1rem; /* Tambahkan margin atas untuk jarak dari info jarak/waktu */
}
</style>