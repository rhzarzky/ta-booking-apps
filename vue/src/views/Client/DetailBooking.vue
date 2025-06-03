<script setup>
import { onMounted, ref, computed } from 'vue'
import { useRoute } from 'vue-router'
import { bookingApi } from '@/api/booking-api'

const route = useRoute()
const booking = ref(null)

// Fetch data saat komponen dimount
onMounted(async () => {
  try {
    const response = await bookingApi.getBookingDetail(route.params.id)
    booking.value = response
  } catch (err) {
    console.error('Gagal mengambil detail booking:', err)
  }
})

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
          <h3 class="text-xl font-semibold text-gray-700 mb-3">Jadwal</h3>
          <div class="bg-blue-50 p-4 rounded-lg flex items-center shadow-sm">
            <svg class="w-5 h-5 text-blue-600 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
            </svg>
            <p class="text-gray-800 text-base">{{ formattedDate }},{{ booking.service.time }} WIB</p>
          </div>
        </div>

        <div>
          <h3 class="text-xl font-semibold text-gray-700 mb-3">Pilihan</h3>
          <div class="bg-blue-50 p-4 rounded-lg flex items-center shadow-sm">
            <svg class="w-5 h-5 text-blue-600 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path d="M13 10V3L4 14h7v7l9-11h-7z" />
            </svg>
            <p class="text-gray-800 text-base">{{ booking.service.option }}</p>
          </div>
        </div>
      </div>

      <div class="mb-10">
        <h3 class="text-xl font-semibold text-gray-700 mb-3">Lokasi</h3>
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
            <p class="text-gray-800 flex items-center">
              <svg class="w-5 h-5 mr-2 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path d="M17.657 16.657L13.414 20.9a2 2 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                <path d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
              </svg>
              {{ booking.service.location }}
            </p>
          </template>
        </div>
      </div>

      <div class="mb-10">
        <h3 class="text-xl font-semibold text-gray-700 mb-3">Catatan</h3>
        <div class="bg-blue-50 p-4 rounded-lg shadow-sm">
          <p class="text-gray-800 italic">{{ booking.service.note || 'Tidak ada catatan tambahan.' }}</p>
        </div>
      </div>

      <div v-if="showCalendarButton" class="text-center mt-10">
        <a :href="generateGoogleCalendarUrl" target="_blank" class="bg-blue-600 hover:bg-blue-700 text-white font-semibold px-8 py-3 rounded-full shadow-lg transition transform hover:scale-105 inline-flex items-center">
          <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
          </svg>
          Tambahkan ke Google Calendar
        </a>
      </div>
    </div>

    <div v-else class="text-center text-gray-500 py-12">
      <p class="text-lg">Sedang memuat detail booking...</p>
      <svg class="animate-spin h-8 w-8 text-blue-500 mx-auto mt-4" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" />
        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z" />
      </svg>
    </div>
  </div>
</template>