<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-50 px-4">
    <div class="bg-white p-8 rounded-lg shadow-md w-full max-w-sm text-center">
      <div class="mb-4 flex justify-center">
        <svg
          xmlns="http://www.w3.org/2000/svg"
          class="h-16 w-16 text-green-500"
          fill="none"
          viewBox="0 0 24 24"
          stroke="currentColor"
          stroke-width="2"
        >
          <path stroke-linecap="round" stroke-linejoin="round" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
      </div>

      <h2 class="text-2xl font-bold text-gray-800 mb-2">Password Berhasil Diubah!</h2>
      <p class="text-gray-600 mb-6">
        Silakan login kembali dengan password baru Anda.
      </p>
      
      <router-link
        to="/login"
        class="inline-flex items-center justify-center px-5 py-2 border border-transparent text-base font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 transition duration-150 ease-in-out"
      >
        Login Sekarang
      </router-link>
    </div>
  </div>
</template>
