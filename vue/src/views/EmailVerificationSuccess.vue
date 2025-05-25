<template>
  <div class="min-h-screen flex items-center justify-center bg-gradient-to-br from-green-100 to-white">
    <div class="bg-white shadow-xl rounded-2xl p-8 max-w-lg w-full text-center animate-fade-in">
      <div class="flex justify-center mb-5">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-16 w-16 text-green-600" fill="none" viewBox="0 0 24 24"
             stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                d="M9 12l2 2l4 -4m2 -2a9 9 0 1 1 -18 0a9 9 0 0 1 18 0z"/>
        </svg>
      </div>
      <h1 class="text-2xl font-bold text-green-700 mb-2">Email Berhasil Diverifikasi!</h1>
      <p class="text-gray-600 mb-6">
        Akun Anda telah aktif. Anda dapat login dan mulai melakukan booking sekarang.
      </p>
      <router-link to="/login"
                   class="inline-block bg-green-600 hover:bg-green-700 text-white font-medium py-2 px-6 rounded-full transition">
        Masuk Sekarang
      </router-link>
    </div>
  </div>
</template>

<script>
export default {
  name: 'EmailVerificationSuccess'
}
</script>

<style scoped>
@keyframes fade-in {
  from {
    opacity: 0;
    transform: scale(0.95);
  }
  to {
    opacity: 1;
    transform: scale(1);
  }
}
.animate-fade-in {
  animation: fade-in 0.5s ease-out;
}
</style>
