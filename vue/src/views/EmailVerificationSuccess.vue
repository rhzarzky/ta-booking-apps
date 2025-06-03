<template>
  <div class="min-h-screen flex items-center justify-center bg-gradient-to-br from-green-50 to-emerald-200 relative overflow-hidden">
    <div class="absolute inset-0 z-0 opacity-10" style="background-image: url('data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNDAiIGhlaWdodD0iNDAiIHZpZXdCb3g9IjAgMCA0MCA0MCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48Y2lyY2xlIGN4PSIyMCIgY3k9IjIwIiByPSIyIiBmaWxsPSIjY2NlY2NjIi8+PC9zdmc+'); background-size: 20px 20px;"></div>

    <div class="bg-white shadow-2xl rounded-3xl p-10 max-w-md w-full text-center relative z-10 animate-fade-in-up">
      <div class="flex justify-center mb-6">
        <svg class="h-20 w-20 text-green-500 animate-bounce-in" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
          <path stroke-linecap="round" stroke-linejoin="round" d="M9 12l2 2l4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
      </div>
      <h1 class="text-3xl font-extrabold text-green-700 mb-3">Verifikasi Berhasil! 🎉</h1>
      <p class="text-gray-700 text-lg mb-7 leading-relaxed">
        Selamat datang! Akun Anda kini aktif. Anda bisa login dan mulai melakukan booking.
      </p>
      <router-link to="/login"
                   class="inline-block bg-green-600 hover:bg-green-700 text-white font-semibold py-3 px-8 rounded-full transition duration-300 ease-in-out transform hover:scale-105 shadow-lg">
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
@keyframes fade-in-up {
  from {
    opacity: 0;
    transform: translateY(20px) scale(0.98);
  }
  to {
    opacity: 1;
    transform: translateY(0) scale(1);
  }
}

@keyframes bounce-in {
  0% {
    transform: scale(0.1);
    opacity: 0;
  }
  60% {
    transform: scale(1.2);
    opacity: 1;
  }
  100% {
    transform: scale(1);
  }
}

.animate-fade-in-up {
  animation: fade-in-up 0.6s ease-out forwards;
}

.animate-bounce-in {
  animation: bounce-in 0.8s ease-out;
}
</style>