<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-100 px-4">
    <div class="bg-white p-6 rounded-xl shadow-lg w-full max-w-md">
      <h2 class="text-2xl font-bold text-center text-gray-800 mb-6">Lupa Password</h2>

      <form @submit.prevent="submitEmail">
        <div class="mb-4">
          <label for="email" class="block text-sm font-medium text-gray-700 mb-1">Alamat Email</label>
          <input
            id="email"
            v-model="email"
            type="email"
            placeholder="Masukkan email kamu"
            class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
            required
          />
          <p v-if="errors.general" class="text-red-500 text-sm mt-1">{{ errors.general }}</p>
        </div>

        <button
          type="submit"
          class="w-full bg-blue-600 text-white py-2 rounded-lg flex items-center justify-center hover:bg-blue-700 transition duration-200"
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
          {{ loading ? 'Mengirim...' : 'Kirim OTP' }}
        </button>

        <button
          type="button"
          class="mt-4 w-full border border-gray-300 text-gray-600 py-2 rounded-lg hover:bg-gray-100 transition duration-200"
          @click="router.push('/login')"
        >
          ← Kembali ke Login
        </button>
      </form>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const email = ref('')
const router = useRouter()
const auth = useAuthStore()
const { handleSendOtp, errors, loading } = auth

const submitEmail = async () => {
  try {
    const response = await handleSendOtp(email.value);

    if (response?.status === 'success' || response?.message === 'OTP sent') {
      sessionStorage.setItem('verify-otp', email.value);
      router.push('/verify-otp');
    } else {
      console.log('Kondisi navigasi tidak terpenuhi. Respons:', response);
    }
  } catch (e) {
    
  }
};
</script>
