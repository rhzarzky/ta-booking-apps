<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-100">
    <div class="bg-white p-6 rounded-lg shadow-md w-full max-w-md">
      <h2 class="text-2xl font-bold text-center text-gray-800 mb-6">Verify OTP</h2>

      <form @submit.prevent="submitOtp">
        <div class="mb-4">
          <input
            v-model="form.otp"
            type="text"
            placeholder="Masukkan Kode OTP"
            class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
            required
          />
        </div>

        <button
          type="submit"
          class="w-full bg-blue-600 text-white py-2 rounded-lg hover:bg-blue-700 transition duration-200 flex justify-center items-center"
          :disabled="loading"
        >
          <svg
            v-if="loading"
            class="animate-spin h-5 w-5 mr-2 text-white"
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
          >
            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" />
            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
          </svg>
          {{ loading ? 'Verifying...' : 'Verify' }}
        </button>

        <button
          type="button"
          class="mt-3 w-full text-blue-600 hover:underline text-sm disabled:opacity-50"
          @click="resendOtp"
          :disabled="loading || resendCooldown > 0"
        >
          Resend OTP <span v-if="resendCooldown > 0">({{ resendCooldown }}s)</span>
        </button>

        <p v-if="errors?.general" class="text-red-500 text-sm mt-3 text-center">{{ errors.general }}</p>
      </form>
    </div>
  </div>
</template>

<script setup>
import { reactive, ref, computed, onMounted } from 'vue'
import { useAuthStore } from '@/stores/auth'
import { useRouter } from 'vue-router'

const form = reactive({ otp: '' })
const resendCooldown = ref(0)
const router = useRouter()
const auth = useAuthStore()

const loading = computed(() => auth.loading)
const errors = computed(() => auth.errors)
const email = sessionStorage.getItem('verify-otp')

const submitOtp = async () => {
  try {
    const response = await auth.handleVerifyOtp(form.otp)
    if (response?.status === 'success') {
      router.push('/reset-password')
    }
  } catch (error) {
    console.error('OTP verification error:', error)
  }
}

const resendOtp = async () => {
  try {
    await auth.handleResendOtp(email)
    alert('OTP has been resent')
    startCooldown()
  } catch (e) {
    console.error('Resend error:', e)
  }
}

const startCooldown = () => {
  resendCooldown.value = 60
  const interval = setInterval(() => {
    resendCooldown.value--
    if (resendCooldown.value <= 0) clearInterval(interval)
  }, 1000)
}

onMounted(() => {
  if (!email) {
    router.push('/forgot-password')
  } else {
    startCooldown()
  }
})
</script>
