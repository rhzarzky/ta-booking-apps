<template>
  <div class="max-w-5xl mx-auto p-6 bg-white shadow-xl rounded-xl mt-4">
    <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
      <!-- LEFT SIDE: Booking Form -->
      <div class="bg-gray-50 p-6 rounded-xl shadow-md">
        <h3 class="text-xl font-semibold text-gray-800 mb-6 flex items-center gap-2">
          <ClipboardEdit class="w-6 h-6 text-indigo-600" /> Booking Form
        </h3>

        <form @submit.prevent="submitBooking" class="space-y-5">
          <!-- Date Picker as Buttons -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Select Date</label>
            <div class="flex flex-wrap gap-2">
              <button
                v-for="(d, i) in availableDates"
                :key="i"
                type="button"
                @click="selectDate(d)"
                :class="[
                  'px-4 py-2 rounded-lg border text-sm transition-all duration-150 ease-in-out',
                  form.date === d
                    ? 'bg-indigo-600 text-white'
                    : 'bg-white text-gray-800 border-gray-300 hover:bg-gray-100'
                ]"
              >
                {{ formatDateShort(d) }}
              </button>
            </div>
            <p v-if="form.date && !availableDates.includes(form.date)" class="text-sm text-red-500 mt-1">
              Tanggal tidak tersedia.
            </p>
          </div>

          <!-- Time Slot Buttons -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Select Time</label>
            <div class="flex flex-wrap gap-2">
              <button
                v-for="(t, i) in service?.time || []"
                :key="i"
                type="button"
                @click="form.time = t"
                :class="[
                  'px-3 py-2 rounded-lg border text-sm',
                  form.time === t
                    ? 'bg-indigo-600 text-white'
                    : 'bg-white text-gray-800 border-gray-300 hover:bg-gray-100'
                ]"
              >
                {{ t }}
              </button>
            </div>
          </div>

          <!-- Meeting Method as Buttons -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Meeting Method</label>
            <div class="flex flex-wrap gap-2">
              <button
                v-for="(opt, i) in service?.option || []"
                :key="i"
                type="button"
                @click="form.option = opt"
                :class="[
                  'px-4 py-2 rounded-lg border text-sm transition-all duration-150 ease-in-out',
                  form.option === opt
                    ? 'bg-indigo-600 text-white'
                    : 'bg-white text-gray-800 border-gray-300 hover:bg-gray-100'
                ]"
              >
                {{ opt }}
              </button>
            </div>
          </div>

          <!-- Notes -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Notes</label>
            <textarea
              v-model="form.note"
              rows="3"
              class="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm resize-none"
              placeholder="Tambahkan catatan jika diperlukan..."
            ></textarea>
          </div>

          <!-- Submit -->
          <button
            type="submit"
            class="w-full bg-indigo-600 hover:bg-indigo-700 text-white font-medium py-2 px-4 rounded-lg transition"
            :disabled="isSubmitting || !availableDates.includes(form.date)"
          >
            {{ isSubmitting ? 'Mengirim...' : 'Confirm Booking' }}
          </button>
        </form>
      </div>

      <!-- RIGHT SIDE: Service Details -->
      <div class="md:col-span-2">
        <img
          :src="service?.image || fallbackImage"
          alt="Service"
          class="w-full h-64 object-cover rounded-xl mb-2"
        />

        <h2 class="text-3xl font-bold text-gray-800 mb-2">{{ service?.title }}</h2>
        <p class="text-gray-600 mb-6 leading-relaxed">{{ service?.description }}</p>

        <div class="space-y-4 text-gray-700 text-base">
          <div class="flex items-center gap-3">
            <MapPin class="w-5 h-5 text-indigo-600" />
            <span><strong>Location:</strong> {{ service?.location }}</span>
          </div>

          <div class="flex items-center gap-3">
            <ListChecks class="w-5 h-5 text-indigo-600" />
            <span><strong>Options:</strong> {{ service?.option?.join(', ') }}</span>
          </div>

          <div class="flex items-center gap-3">
            <CalendarClock class="w-5 h-5 text-indigo-600" />
            <span><strong>Days:</strong> {{ service?.days?.join(', ') }}</span>
          </div>

          <div class="flex items-center gap-3">
            <Clock class="w-5 h-5 text-indigo-600" />
            <span><strong>Time:</strong> {{ service?.time?.join(', ') }}</span>
          </div>

          <div class="flex items-center gap-3">
            <CalendarRange class="w-5 h-5 text-indigo-600" />
            <span>
              <strong>Date Range:</strong>
              {{ formatDate(service?.date?.[0]?.date) }} - {{ formatDate(service?.end_date) }}
            </span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useServiceStore } from '@/stores/service'
import fallbackImage from '@/assets/images/booking.jpg'

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

const availableDates = computed(() => {
  if (!service.value?.date) return []

  const today = new Date()
  today.setHours(0, 0, 0, 0) // Normalize to midnight

  return service.value.date
    .map(d => d.date)
    .filter(dateStr => {
      const date = new Date(dateStr)
      date.setHours(0, 0, 0, 0)
      return date >= today
    })
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

const formatDateShort = (dateStr) => {
  if (!dateStr) return '-'
  return new Date(dateStr).toLocaleDateString('en-US', {
    month: 'short',
    day: '2-digit',
  })
}

const selectDate = (date) => {
  form.value.date = date
}

onMounted(async () => {
  await store.fetchServiceById(route.params.id)
  service.value = store.service
})

const submitBooking = async () => {
  try {
    isSubmitting.value = true
    const payload = {
      time: form.value.time,
      date: form.value.date,
      note: form.value.note,
      option: form.value.option,
    }

    await store.bookService(route.params.id, payload)
    alert('Service booked successfully, awaiting approval.')
    router.push('/client/activity')
  } catch (err) {
    console.error(err)
    alert('Unfortunately, this service is already booked at that time. Please select another date.')
  } finally {
    isSubmitting.value = false
  }
}
</script>
