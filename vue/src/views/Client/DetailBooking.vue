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
        <h2 class="text-2xl font-bold mb-1">{{ title }}</h2>
        <p class="text-gray-600 mb-4">{{ description }}</p>

        <div class="flex items-center justify-between mb-4 text-sm">
          <span :class="statusClass">{{ status }}</span>
          <span class="text-gray-500">{{ scheduleDate }}</span>
        </div>

        <!-- Calendar Date Picker -->
        <div class="mb-4">
          <h3 class="font-semibold mb-1">Select Day</h3>
          <input
            type="date"
            class="border rounded px-3 py-2"
            :min="minDate"
            :max="maxDate"
            v-model="selectedDate"
          />
          <div v-if="selectedDate" class="mt-2 text-sm text-gray-600">
            Selected date: <span class="font-medium">{{ selectedDate }}</span>
          </div>
        </div>

        <!-- Time -->
        <div class="mb-4">
          <h3 class="font-semibold mb-1">Select Time</h3>
          <div class="bg-gray-100 p-3 rounded-md">
            <label class="text-sm text-gray-600 mb-2 block">Available Times</label>
            <div class="overflow-x-auto whitespace-nowrap flex gap-3 pb-2">
              <button
                v-for="(time, index) in availableTimes"
                :key="index"
                @click="selectedTime = time"
                :class="[
                  'min-w-max px-4 py-2 rounded-full border text-sm',
                  selectedTime === time ? 'bg-indigo-600 text-white border-indigo-600' : 'bg-white text-gray-700 hover:bg-indigo-100'
                ]"
              >
                {{ time }}
              </button>
            </div>
          </div>
        </div>

        <!-- Option (Online/Offline) -->
        <div class="mb-4">
          <h3 class="font-semibold mb-1">Option</h3>
          <div class="flex flex-wrap gap-3 bg-gray-100 p-3 rounded-md">
            <button
              :class="[
                'border px-3 py-1 rounded flex items-center justify-center',
                selectedMethod === 'offline' ? 'bg-indigo-400 text-white' : 'hover:bg-gray-200'
              ]"
              @click="handleSelect('offline')"
            >
              <span>Offline</span>
            </button>

            <button
              :class="[
                'border px-3 py-1 rounded flex items-center justify-center',
                selectedMethod === 'online' ? 'bg-indigo-400 text-white' : 'hover:bg-gray-200'
              ]"
              @click="handleSelect('online')"
            >
              <span>Online</span>
            </button>
          </div>

          <div v-if="userAddress && selectedMethod === 'offline'" class="mt-3 text-sm text-gray-600">
            📍 Lokasi Anda: <span class="font-medium">{{ userAddress }}</span>
          </div>
        </div>

        <!-- Note -->
        <div class="mb-4">
          <label class="block mb-1 font-medium">Note :</label>
          <textarea
            rows="4"
            v-model="note"
            placeholder="Add any additional notes..."
            class="w-full border rounded px-3 py-2"
          ></textarea>
        </div>

        <div class="text-right">
          <button
            @click="submitBooking"
            class="bg-indigo-600 text-white px-4 py-2 rounded hover:bg-indigo-700"
          >
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
const selectedDate = ref('')
const note = ref('')

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

const today = new Date()
const minDate = today.toISOString().split('T')[0]
const maxDate = new Date(today.getFullYear(), today.getMonth(), today.getDate() + 6)
  .toISOString()
  .split('T')[0]

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

const getCurrentLocation = () => {
  return new Promise((resolve, reject) => {
    if (!navigator.geolocation) {
      reject(new Error('Geolocation tidak didukung'))
    }
    navigator.geolocation.getCurrentPosition(resolve, reject)
  })
}

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
    selectedMethod.value = 'online'
    userAddress.value = ''
  }
}

const scheduleDate = ref('')
onMounted(() => {
  if (route.query.date) {
    const d = new Date(route.query.date)
    const options = { day: 'numeric', month: 'short', year: 'numeric' }
    scheduleDate.value = d.toLocaleDateString('en-GB', options)
  }
})

const statusClass = computed(() => {
  return status === 'Available Now'
    ? 'bg-green-100 text-green-700 px-2 py-1 rounded'
    : 'bg-gray-100 text-gray-700 px-2 py-1 rounded'
})
</script>

<style scoped>
</style>
