<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useServiceStore } from '@/stores/service'
import fallbackImage from '@/assets/images/booking.jpg'

// Lucide Icons
import {
  MapPin,
  ListChecks,
  CalendarClock,
  CalendarRange,
  ClipboardEdit,
  Clock,
} from 'lucide-vue-next'

const route = useRoute()
const router = useRouter()
const store = useServiceStore()
const service = ref(null)
const isSubmitting = ref(false)

const form = ref({
  date: '',
  time: '',
  option: '',
  note: '',
})

onMounted(async () => {
  await store.fetchServiceById(route.params.id)
  service.value = store.service
})

const formatDate = (dateStr) => {
  if (!dateStr) return '-'
  return new Date(dateStr).toLocaleDateString('en-US', {
    weekday: 'short',
    day: '2-digit',
    month: 'short',
    year: 'numeric',
  })
}

const submitBooking = async () => {
  try {
    isSubmitting.value = true
    const payload = {
      time: form.value.time,
      date: form.value.date,
      note: form.value.note,
      option: form.value.option,
    }

    console.log('Payload:', payload)

    // Call the API to book service
    await store.bookService(route.params.id, payload)

    alert('Booking berhasil!')
    router.push('/client/activity') // Redirect after booking success
  } catch (err) {
    console.error(err)
    alert('Gagal booking')
  } finally {
    isSubmitting.value = false
  }
}
</script>


<template>
  <div class="max-w-4xl mx-auto p-6 bg-white shadow-lg rounded-lg mt-1">
    <div class="flex flex-col md:flex-row gap-6">
      <!-- Left Content -->
      <div class="md:w-2/3">
        <h2 class="text-2xl font-bold text-gray-800 mb-2 flex items-center gap-2">
          <span>{{ service?.title }}</span>
        </h2>
        <p class="text-gray-600 mb-4">{{ service?.description }}</p>

        <img
          :src="service?.image || fallbackImage"
          alt="Service"
          class="w-full rounded-lg object-cover mb-4"
        />

        <!-- Info Section -->
        <div class="space-y-3 text-sm text-gray-700">
          <p class="flex items-center gap-2">
            <MapPin class="w-5 h-5 text-indigo-600" /> <strong>Location:</strong>
            {{ service?.location }}
          </p>
          <p class="flex items-center gap-2">
            <ListChecks class="w-5 h-5 text-indigo-600" />
            <strong>Options:</strong> {{ service?.option?.join(', ') }}
          </p>
          <p class="flex items-center gap-2">
            <CalendarClock class="w-5 h-5 text-indigo-600" />
            <strong>Days:</strong> {{ service?.days?.join(', ') }}
          </p>
          <p class="flex items-center gap-2">
            <Clock class="w-5 h-5 text-indigo-600" />
            <strong>Time:</strong> {{ service?.time?.join(', ') }}
          </p>
          <p class="flex items-center gap-2">
            <CalendarRange class="w-5 h-5 text-indigo-600" />
            <strong>Date Range:</strong> {{ formatDate(service?.date?.[0]?.date) }} -
            {{ formatDate(service?.end_date) }}
          </p>
        </div>
      </div>

      <!-- Right Booking Form -->
      <div class="md:w-1/3 bg-gray-50 p-5 rounded-lg shadow">
        <h3 class="text-lg font-semibold mb-4 text-gray-800 flex items-center gap-2">
          <ClipboardEdit class="w-5 h-5 text-indigo-600" /> Book Service
        </h3>
        <form @submit.prevent="submitBooking" class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-700">Select Date</label>
            <select
              v-model="form.date"
              class="w-full mt-1 border-gray-300 rounded-md shadow-sm"
              required
            >
              <option v-for="(d, i) in service?.date || []" :key="i" :value="d.date">
                {{ formatDate(d.date) }}
              </option>
            </select>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700">Select Time</label>
            <select
              v-model="form.time"
              class="w-full mt-1 border-gray-300 rounded-md shadow-sm"
              required
            >
              <option v-for="(t, i) in service?.time || []" :key="i" :value="t">
                {{ t }}
              </option>
            </select>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700">Meeting Method</label>
            <select
              v-model="form.option"
              class="w-full mt-1 border-gray-300 rounded-md shadow-sm"
              required
            >
              <option v-for="(opt, i) in service?.option || []" :key="i" :value="opt">
                {{ opt }}
              </option>
            </select>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700">Notes</label>
            <textarea
              v-model="form.note"
              rows="3"
              class="w-full mt-1 border-gray-300 rounded-md shadow-sm resize-none"
              placeholder="Tambahkan catatan jika diperlukan..."
            />
          </div>

          <button
            type="submit"
            class="w-full bg-indigo-600 hover:bg-indigo-700 text-white font-medium py-2 px-4 rounded-md transition"
            :disabled="isSubmitting"
          >
            {{ isSubmitting ? 'Mengirim...' : 'Confirm Booking' }}
          </button>
        </form>
      </div>
    </div>
  </div>
</template>

