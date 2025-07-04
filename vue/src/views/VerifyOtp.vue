<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-100 px-4 py-8">
    <div class="bg-white p-8 rounded-xl shadow-lg w-full max-w-md">
      <div class="text-center mb-6">
        <svg class="mx-auto h-12 w-12 text-blue-600" fill="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8zm-1-13h2v6h-2zm0 8h2v2h-2z"/>
        </svg>
        </div>

      <h2 class="text-3xl font-extrabold text-center text-gray-800 mb-3">Verify OTP</h2>
      <p class="text-center text-sm text-gray-500 mb-6 px-2">
        Kami telah mengirimkan kode verifikasi ke email Anda (<span class="font-semibold text-gray-700">{{ maskedEmail }}</span>). Silakan masukkan kode di bawah ini.
      </p>

      <form @submit.prevent="submitOtp">
        <div class="mb-4">
          <label for="otp-input" class="block text-sm font-semibold text-gray-700 mb-2 sr-only">Kode OTP</label>
          <div class="flex justify-center gap-3">
            <input
              v-for="(digit, index) in otpDigits"
              :key="index"
              :id="`otp-${index}`"
              v-model="otpDigits[index]"
              type="text"
              maxlength="1"
              @input="handleOtpInput(index, $event)"
              @keydown="handleOtpKeydown(index, $event)"
              class="w-12 h-12 text-center text-2xl font-bold border border-gray-300 rounded-lg 
                     focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 
                     transition duration-200 shadow-sm hover:border-gray-400"
              :class="{ 'border-red-500': errors?.general && otpDigits.every(d => d !== '') }"
              inputmode="numeric"
              pattern="[0-9]*"
              required
            />
          </div>
          <p v-if="errors?.general" class="text-red-500 text-sm mt-3 text-center">{{ errors.general }}</p>
        </div>

        <button
          type="submit"
          class="w-full bg-blue-600 text-white py-2.5 rounded-lg flex items-center justify-center 
                 font-semibold shadow-md hover:bg-blue-700 hover:shadow-lg 
                 transition-all duration-300 transform hover:scale-105 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-opacity-50"
          :disabled="loading || otpDigits.some(d => d === '')"
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
          class="mt-4 w-full text-blue-600 font-medium hover:underline text-sm 
                 disabled:opacity-50 disabled:cursor-not-allowed transition duration-200"
          :class="{ 'text-gray-400': resendCooldown > 0 }"
          @click="resendOtp"
          :disabled="loading || resendCooldown > 0"
        >
          Resend OTP <span v-if="resendCooldown > 0">({{ resendCooldown }}s)</span>
        </button>
        
        <button
          type="button"
          class="mt-3 w-full border border-gray-300 text-gray-600 py-2.5 rounded-lg 
                 font-semibold hover:bg-gray-100 hover:border-gray-400 
                 transition duration-200 focus:outline-none focus:ring-2 focus:ring-gray-300 focus:ring-opacity-50"
          @click="router.push('/forgot-password')"
        >
          ← Change Email
        </button>
      </form>
    </div>
  </div>
</template>

<script setup>
import { reactive, ref, computed, onMounted, watch } from 'vue'
import { useAuthStore } from '@/stores/auth' // Pastikan path ini benar
import { useRouter } from 'vue-router'

// Store
const auth = useAuthStore()
const router = useRouter()

// State
const otpDigits = reactive(['', '', '', '', '', '']) // 6 digit OTP
const resendCooldown = ref(0)
let countdownInterval = null; // Untuk menyimpan referensi interval

// Computed
const loading = computed(() => auth.loading)
const errors = computed(() => auth.errors)
const email = sessionStorage.getItem('verify-otp') // Email dari Forgot Password

// Computed untuk menampilkan email yang di-mask (opsional)
const maskedEmail = computed(() => {
  if (!email) return '';
  const [name, domain] = email.split('@');
  if (name.length <= 2) return `**@${domain}`;
  return `${name[0]}**${name[name.length - 1]}@${domain}`;
});


// --- OTP Input Handling ---
const handleOtpInput = (index, event) => {
  // Hanya izinkan angka
  const value = event.target.value.replace(/[^0-9]/g, '');
  otpDigits[index] = value;

  // Fokus ke input berikutnya jika diisi dan bukan yang terakhir
  if (value && index < otpDigits.length - 1) {
    document.getElementById(`otp-${index + 1}`).focus();
  }
  // Clear error saat mulai mengetik
  if (errors.value) errors.value.general = null;
};

const handleOtpKeydown = (index, event) => {
  // Pindah fokus ke input sebelumnya saat backspace pada input kosong
  if (event.key === 'Backspace' && !otpDigits[index] && index > 0) {
    document.getElementById(`otp-${index - 1}`).focus();
  }
};

// Gabungkan digit OTP menjadi satu string
const combinedOtp = computed(() => otpDigits.join(''));

// --- Actions ---
const submitOtp = async () => {
  // Pastikan semua digit terisi
  if (combinedOtp.value.length !== otpDigits.length) {
    if (errors.value) errors.value.general = 'Please enter the complete OTP.';
    return;
  }
  
  if (errors.value) errors.value.general = null; // Clear previous errors

  try {
    const response = await auth.handleVerifyOtp(combinedOtp.value);
    if (response?.status === 'success') {
      router.push('/reset-password');
      // Bersihkan session storage setelah berhasil
      sessionStorage.removeItem('verify-otp'); 
    } else {
        // Tangani jika ada pesan error dari backend tapi bukan success status
        if (auth.errors) auth.errors.general = response.message || 'OTP verification failed.';
    }
  } catch (error) {
    console.error('OTP verification error:', error);
    if (auth.errors) auth.errors.general = error.response?.data?.message || 'An unexpected error occurred.';
  }
};

const resendOtp = async () => {
  if (!email) {
    triggerAlert('Email tidak ditemukan. Kembali ke halaman lupa password.', 'error');
    router.push('/forgot-password');
    return;
  }
  if (errors.value) errors.value.general = null; // Clear previous errors
  try {
    await auth.handleResendOtp(email);
    // Jika resend berhasil, bersihkan input OTP
    otpDigits.forEach((_, i) => otpDigits[i] = '');
    triggerAlert('Kode OTP baru telah dikirim!', 'success');
    startCooldown();
  } catch (e) {
    console.error('Resend error:', e);
    triggerAlert('Gagal mengirim ulang OTP: ' + (e.response?.data?.message || e.message), 'error');
  }
};

const startCooldown = () => {
  resendCooldown.value = 60; // Cooldown 60 detik
  if (countdownInterval) clearInterval(countdownInterval); // Hentikan interval lama jika ada
  countdownInterval = setInterval(() => {
    resendCooldown.value--;
    if (resendCooldown.value <= 0) {
      clearInterval(countdownInterval);
      countdownInterval = null; // Reset interval reference
    }
  }, 1000);
};

// Mock function for alert (replace with your actual AlertStatus component logic)
const triggerAlert = (message, type) => {
    console.log(`ALERT (${type}): ${message}`);
    // Implementasi nyata akan menggunakan showAlert, alertMessage, alertType dari state global/parent
    // Misalnya: emit('show-alert', { message, type });
};


// Lifecycle Hook
onMounted(() => {
  if (!email) {
    router.push('/forgot-password');
  } else {
    // Mulai cooldown saat halaman dimuat jika email ada
    // Asumsi: jika user datang dari forgot-password, OTP baru saja dikirim
    // Jika user me-refresh halaman, cooldown akan dimulai dari 60s lagi
    // Pertimbangkan untuk menyimpan resendCooldown di session/local storage jika ingin persisten
    startCooldown(); 
  }
});

// Bersihkan interval saat komponen di-unmount
onMounted(() => {
    return () => {
        if (countdownInterval) {
            clearInterval(countdownInterval);
        }
    };
});
</script>

<style scoped>
/* Optional: CSS untuk input OTP agar tetap rapi */
input[type="text"] {
  -moz-appearance: textfield; /* For Firefox */
}

input::-webkit-outer-spin-button,
input::-webkit-inner-spin-button {
  -webkit-appearance: none;
  margin: 0;
}
</style>