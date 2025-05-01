<template>
  <div class="p-8 bg-gray-100 min-h-screen">
    <!-- Breadcrumb -->
    <nav class="text-sm text-gray-500 mb-4">
      <router-link to="/client/dashboard" class="hover:underline">Dashboard</router-link> /
      <router-link to="/client/activity" class="hover:underline">Activity</router-link> /
      <span class="text-indigo-600 capitalize">Detail Booking</span>
    </nav>

    <!-- Card -->
    <div class="bg-white rounded-xl overflow-hidden shadow-md">
      <img :src="image" alt="Booking image" class="w-full h-64 object-cover" />

      <div class="p-6">
        <!-- Title -->
        <h2 class="text-2xl font-bold mb-1">{{ title }}</h2>
        <p class="text-gray-600 mb-4">{{ description }}</p>

        <!-- Status & Date -->
        <div class="flex items-center justify-between mb-4 text-sm">
          <span :class="statusClass">{{ status }}</span>
          <span class="text-gray-500">{{ date }}</span>
        </div>

<!-- Schedule -->
<div class="mb-4">
  <h3 class="font-semibold mb-1">Schedule</h3>
  <div class="bg-gray-100 p-3 rounded-md">
    <label class="text-sm text-gray-600 mb-2 block">Time & Date</label>

    <!-- Horizontal Scrollable Time Picker -->
    <div class="overflow-x-auto whitespace-nowrap flex gap-3 pb-2">
      <button
        v-for="(time, index) in availableTimes"
        :key="index"
        @click="selectedTime = time"
        :class="[
          'min-w-max px-4 py-2 rounded-full border text-sm',
          selectedTime === time
            ? 'bg-indigo-600 text-white border-indigo-600'
            : 'bg-white text-gray-700 hover:bg-indigo-100'
        ]"
      >
        {{ time }}
      </button>
    </div>

    <!-- Tanggal -->
  </div>
</div>


        <!-- Location -->
        <div class="mb-4">
          <h3 class="font-semibold mb-1">Location</h3>
          <div class="flex flex-wrap gap-3 bg-gray-100 p-3 rounded-md">
            <button
              :class="[
                'border px-3 py-1 rounded flex items-center justify-center',
                selectedMethod === 'offline' ? 'bg-indigo-400 text-white' : 'hover:bg-gray-200'
              ]"
              @click="handleSelect('offline')"
            >
              <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16"
                fill="currentColor" class="bi bi-geo-alt mr-2" viewBox="0 0 16 16">
                <path
                  d="M12.166 8.94c-.524 1.062-1.234 2.12-1.96 
                  3.07A32 32 0 0 1 8 14.58a32 32 0 0 
                  1-2.206-2.57c-.726-.95-1.436-2.008-1.96-3.07C3.304 
                  7.867 3 6.862 3 6a5 5 0 0 1 
                  10 0c0 .862-.305 1.867-.834 2.94M8 
                  16s6-5.686 6-10A6 6 0 0 0 
                  2 6c0 4.314 6 10 6 10" />
                <path
                  d="M8 8a2 2 0 1 1 0-4 
                  2 2 0 0 1 0 4m0 1a3 3 0 1 0 0-6 
                  3 3 0 0 0 0 6" />
              </svg>
              <span> In-person meeting</span>
            </button>

            <button
              :class="[
                'border px-3 py-1 rounded flex items-center justify-center',
                selectedMethod === 'zoom' ? 'bg-indigo-400 text-white' : 'hover:bg-gray-200'
              ]"
              @click="handleSelect('zoom')"
            >
              <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16"
                fill="currentColor" class="bi bi-camera-video mr-2" viewBox="0 0 16 16">
                <path fill-rule="evenodd"
                  d="M0 5a2 2 0 0 1 2-2h7.5a2 2 0 0 1 
                  1.983 1.738l3.11-1.382A1 1 0 0 1 
                  16 4.269v7.462a1 1 0 0 1-1.406.913l-3.111-1.382A2 
                  2 0 0 1 9.5 13H2a2 2 0 0 1-2-2zm11.5 
                  5.175 3.5 1.556V4.269l-3.5 1.556zM2 
                  4a1 1 0 0 0-1 1v6a1 1 0 0 0 
                  1 1h7.5a1 1 0 0 0 1-1V5a1 1 0 0 
                  0-1-1z" />
              </svg>
              <span>Zoom</span>
            </button>
          </div>

          <!-- Alamat user jika memilih offline -->
          <div v-if="userAddress && selectedMethod === 'offline'" class="mt-3 text-sm text-gray-600">
            📍 Lokasi Anda: <span class="font-medium">{{ userAddress }}</span>
          </div>
        </div>

        <!-- Note -->
        <div class="mb-4">
          <label class="block mb-1 font-medium">Note :</label>
          <textarea
            rows="4"
            placeholder="Add any additional notes..."
            class="w-full border rounded px-3 py-2"
          ></textarea>
        </div>

        <!-- Submit Button -->
        <div class="text-right">
          <button class="bg-indigo-600 text-white px-4 py-2 rounded hover:bg-indigo-700">
            Confirm Booking
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute } from 'vue-router'

const route = useRoute()

const title = route.query.title || 'Default Title'
const description = route.query.description || 'Default description'
const status = route.query.status || 'Available Now'
const date = route.query.date || '2025-02-07'
const image = route.query.image || 'https://via.placeholder.com/640x360'

const selectedMethod = ref('')
const userLocation = ref(null)
const userAddress = ref('')
const selectedTime = ref('')


const availableTimes = [
  '07:00 - 08:00 AM',
  '08:00 - 09:00 AM',
  '09:00 - 10:00 AM',
  '10:00 - 11:00 AM',
  '11:00 - 12:00 PM',
  '13:00 - 14:00 PM',
  '14:00 - 15:00 PM',
  '15:00 - 16:00 PM',
  '16:00 - 17:00 PM'
]



// Convert GPS ke alamat
const fetchAddressFromCoords = async (lat, lon) => {
  try {
    const response = await fetch(
      `https://nominatim.openstreetmap.org/reverse?lat=${lat}&lon=${lon}&format=json`
    )
    const data = await response.json()
    userAddress.value = data.display_name || 'Alamat tidak ditemukan'
  } catch (error) {
    console.error('Gagal mendapatkan alamat:', error)
    userAddress.value = 'Gagal mengambil alamat'
  }
}

// Ambil lokasi pengguna
const getCurrentLocation = () => {
  return new Promise((resolve, reject) => {
    if (!navigator.geolocation) {
      reject(new Error('Geolocation tidak didukung'))
    }
    navigator.geolocation.getCurrentPosition(resolve, reject)
  })
}

// Aksi tombol
const handleSelect = async (method) => {
  if (method === 'offline') {
    try {
      const position = await getCurrentLocation()
      userLocation.value = position
      selectedMethod.value = 'offline'

      const { latitude, longitude } = position.coords
      await fetchAddressFromCoords(latitude, longitude)
    } catch (error) {
      alert('Mohon izinkan akses lokasi terlebih dahulu untuk memilih pertemuan langsung.')
    }
  } else {
    selectedMethod.value = method
    userAddress.value = ''
  }
}

// Format tanggal
const scheduleDate = ref('')
onMounted(() => {
  if (route.query.date) {
    const date = new Date(route.query.date)
    const options = { day: 'numeric', month: 'short', year: 'numeric' }
    scheduleDate.value = date.toLocaleDateString('en-GB', options)
  }
})

// Warna status
const statusClass = computed(() => {
  return status === 'Available Now'
    ? 'bg-green-100 text-green-700 px-2 py-1 rounded'
    : 'bg-gray-100 text-gray-700 px-2 py-1 rounded'
})
</script>
