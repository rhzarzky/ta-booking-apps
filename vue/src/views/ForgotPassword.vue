<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-100 px-4 py-8">
    <div class="bg-white p-8 rounded-xl shadow-lg w-full max-w-md">
      <div class="text-center mb-6">
        <svg class="mx-auto h-12 w-12 text-blue-600" fill="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8zm-1-13h2v6h-2zm0 8h2v2h-2z"/>
        </svg>
        </div>

      <h2 class="text-3xl font-extrabold text-center text-gray-800 mb-3">Forgot Password</h2>
      <p class="text-center text-sm text-gray-500 mb-6 px-2">
        Enter your email address to receive a verification code.
      </p>

      <form @submit.prevent="submitEmail">
        <div class="mb-4">
          <label for="email" class="block text-sm font-semibold text-gray-700 mb-1">Email Address</label>
          <div class="relative">
            <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
              <svg class="h-5 w-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"></path>
              </svg>
            </div>
            <input
              id="email"
              v-model="email"
              type="email"
              placeholder="Enter your email"
              class="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg 
                     focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 
                     transition duration-200 shadow-sm hover:border-gray-400"
              required
            />
          </div>
          <p v-if="errors?.general" class="text-red-500 text-sm mt-1">{{ errors.general }}</p>
        </div>

        <button
          type="submit"
          class="w-full bg-blue-600 text-white py-2.5 rounded-lg flex items-center justify-center 
                 font-semibold shadow-md hover:bg-blue-700 hover:shadow-lg 
                 transition-all duration-300 transform hover:scale-105 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-opacity-50"
          :disabled="loading"
        >
          <svg
            v-if="loading"
            class="animate-spin h-5 w-5 text-white mr-2"
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
          >
            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"></path>
          </svg>
          {{ loading ? 'Sending...' : 'Send OTP' }}
        </button>

        <button
          type="button"
          class="mt-4 w-full border border-gray-300 text-gray-600 py-2.5 rounded-lg 
                 font-semibold hover:bg-gray-100 hover:border-gray-400 
                 transition duration-200 focus:outline-none focus:ring-2 focus:ring-gray-300 focus:ring-opacity-50"
          @click="router.push('/login')"
        >
          ← Back to Login
        </button>
      </form>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth' // Pastikan path ini benar

const email = ref('')
const router = useRouter()
const auth = useAuthStore()

const loading = computed(() => auth.loading)
const errors = computed(() => auth.errors) // Asumsikan `auth.errors` adalah objek, misal { general: '...' }
const handleSendOtp = auth.handleSendOtp

const submitEmail = async () => {
  try {
    // Kosongkan error sebelumnya sebelum mencoba mengirim
    if (auth.errors) auth.errors.general = null; 

    const response = await handleSendOtp(email.value)

    if (response?.status === 'success' || response?.message === 'OTP sent') {
      sessionStorage.setItem('verify-otp', email.value)
      router.push('/verify-otp')
    } else if (response?.message) {
        // Tangani pesan dari backend yang bukan status 'success'
        // Jika backend mengirim { message: 'Email not found' }, tampilkan di sini
        if (auth.errors) auth.errors.general = response.message;
    }
  } catch (e) {
    console.error('Send OTP Error:', e)
    // Tangani error umum atau network error
    if (auth.errors) auth.errors.general = e.response?.data?.message || 'Failed to send OTP. Please try again.';
  }
}
</script>