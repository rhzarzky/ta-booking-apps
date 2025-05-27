<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-100">
    <div class="bg-white p-6 rounded-lg shadow-md w-full max-w-md">
      <h2 class="text-2xl font-bold text-center text-gray-800 mb-6">Verifikasi OTP</h2>

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
          class="w-full bg-blue-600 text-white py-2 rounded-lg hover:bg-blue-700 transition duration-200"
          :disabled="loading"
        >
          {{ loading ? 'Memverifikasi...' : 'Verifikasi' }}
        </button>

        <button
          type="button"
          class="mt-3 w-full text-blue-600 hover:underline text-sm"
          @click="resendOtp"
          :disabled="loading || resendCooldown > 0"
        >
          Kirim Ulang OTP <span v-if="resendCooldown > 0">({{ resendCooldown }}s)</span>
        </button>

        <p v-if="errors.general" class="text-red-500 text-sm mt-3 text-center">{{ errors.general }}</p>
      </form>
    </div>
  </div>
</template>

<script setup>
import { reactive, ref, onMounted } from 'vue'
import { useAuthStore } from '@/stores/auth'
import { useRouter } from 'vue-router'

const form = reactive({
  otp: ''
})

const resendCooldown = ref(0)
const auth = useAuthStore()
const { handleVerifyOtp, handleResendOtp, errors, loading } = auth

const router = useRouter()
const email = sessionStorage.getItem('verif_email')

const submitOtp = async () => {
  try {
    await handleVerifyOtp(form.otp)
    router.push('/reset-password') // Tanpa email di URL
  } catch (error) {
    console.error(error)
  }
}

const resendOtp = async () => {
  try {
    await handleResendOtp(email)
    alert('OTP telah dikirim ulang')
    startCooldown()
  } catch (e) {
    console.error(e)
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
    router.push('/forgot-password') // Redirect jika email tidak ditemukan
  } else {
    startCooldown()
  }
})
</script>
