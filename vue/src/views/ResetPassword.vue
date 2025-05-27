<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-100 px-4">
    <div class="w-full max-w-md bg-white p-6 rounded-lg shadow-md">
      <h2 class="text-2xl font-bold text-center text-gray-800 mb-6">Reset Password</h2>

      <form @submit.prevent="submit" class="space-y-5">
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Password Baru</label>
          <div class="relative">
            <input
              :type="showPassword ? 'text' : 'password'"
              v-model="form.password"
              class="w-full border px-3 py-2 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="Masukkan password baru"
              required
            />
            <button type="button" class="absolute inset-y-0 right-3 flex items-center text-gray-500" @click="togglePassword">
              <i :class="showPassword ? 'i-lucide-eye-off' : 'i-lucide-eye'"></i>
            </button>
          </div>
          <p v-if="errors.password" class="text-red-500 text-sm mt-1">{{ errors.password[0] }}</p>
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Konfirmasi Password</label>
          <div class="relative">
            <input
              :type="showConfirm ? 'text' : 'password'"
              v-model="form.password_confirmation"
              class="w-full border px-3 py-2 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="Ulangi password"
              required
            />
            <button type="button" class="absolute inset-y-0 right-3 flex items-center text-gray-500" @click="toggleConfirm">
              <i :class="showConfirm ? 'i-lucide-eye-off' : 'i-lucide-eye'"></i>
            </button>
          </div>
          <p v-if="errors.password_confirmation" class="text-red-500 text-sm mt-1">{{ errors.password_confirmation[0] }}</p>
        </div>

        <p v-if="errors.general" class="text-red-500 text-sm">{{ errors.general }}</p>

        <button
          type="submit"
          class="w-full bg-blue-600 text-white py-2 rounded-lg hover:bg-blue-700 transition duration-200 flex items-center justify-center"
          :disabled="loading"
        >
          <svg
            v-if="loading"
            class="animate-spin h-5 w-5 mr-2 text-white"
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
          >
            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
            <path
              class="opacity-75"
              fill="currentColor"
              d="M4 12a8 8 0 018-8v4l5-5-5-5v4a10 10 0 100 20v-4l-5 5 5 5v-4a8 8 0 01-8-8z"
            ></path>
          </svg>
          {{ loading ? 'Resetting...' : 'Reset Password' }}
        </button>
      </form>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useAuthStore } from '@/stores/auth'

const form = ref({
  password: '',
  password_confirmation: ''
})

const loading = ref(false)
const errors = ref({})
const showPassword = ref(false)
const showConfirm = ref(false)

const togglePassword = () => (showPassword.value = !showPassword.value)
const toggleConfirm = () => (showConfirm.value = !showConfirm.value)

const auth = useAuthStore()

const submit = async () => {
  errors.value = {}
  loading.value = true
  try {
    await auth.handleResetPassword({ ...form.value })
    alert('Password berhasil direset!')
    window.location.href = '/success-reset'
  } catch (e) {
    errors.value = auth.errors
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.i-lucide-eye,
.i-lucide-eye-off {
  font-size: 1.2rem;
}
</style>
