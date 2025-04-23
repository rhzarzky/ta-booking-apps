<script setup>
import { ref } from 'vue'
import { login } from '/api/auth-api'
import { useRouter } from 'vue-router'

const router = useRouter()
const email = ref('')
const password = ref('')
const loginError = ref('')
const showPassword = ref(false)
const loading = ref(false)

const toggleShowPassword = () => {
  showPassword.value = !showPassword.value
}

const handleLogin = async () => {
  loading.value = true
  loginError.value = ''

  try {
    const response = await login({
      email: email.value,
      password: password.value,
    })

    if (response.status === 'success' && response.user?.role?.includes('user')) {
      // Simpan token dan user ke localStorage
      localStorage.setItem('token', response.token)
      localStorage.setItem('user', JSON.stringify(response.user))

      router.push('/client/dashboard')
    } else {
      loginError.value = 'Akses ditolak: Anda bukan user'
    }
  } catch (err) {
    loginError.value = err.response?.data?.message || 'Email atau Password salah'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="flex h-screen bg-gray-100">
    <!-- Form Login -->
    <div class="w-1/2 flex items-center justify-center p-8">
      <div class="w-full max-w-md">
        <!-- Logo -->
        <img src="@/assets/images/Appointly.png" alt="Logo Appointly" class="h-10 mb-6" />

        <h2 class="text-3xl font-bold text-gray-800">Welcome Back!</h2>
        <p class="text-gray-500 mb-6">Login to continue to your account.</p>

        <!-- Error Message -->
        <div v-if="loginError" class="mb-4 text-red-500 font-semibold text-center">
          {{ loginError }}
        </div>

        <!-- Form Login -->
        <form @submit.prevent="handleLogin" class="space-y-4">
          <div>
            <label class="block text-gray-700 font-medium">Email</label>
            <input
              type="email"
              v-model="email"
              placeholder="Jhondoe@gmail.com"
              class="w-full px-4 py-3 border rounded-lg focus:ring-2 focus:ring-indigo-400"
              required
            />
          </div>
          <div>
            <label class="block text-gray-700 font-medium">Password</label>
            <div class="relative">
              <input
                :type="showPassword ? 'text' : 'password'"
                v-model="password"
                placeholder="Enter your password"
                class="w-full px-4 py-3 border rounded-lg focus:ring-2 focus:ring-indigo-400"
                required
              />
              <!-- SVG Toggle -->
              <svg
                xmlns="http://www.w3.org/2000/svg"
                width="20"
                height="20"
                fill="currentColor"
                class="absolute right-4 top-1/2 transform -translate-y-1/2 text-gray-500 cursor-pointer"
                @click="toggleShowPassword"
                viewBox="0 0 16 16"
              >
                <template v-if="!showPassword">
                  <path d="M10.5 8a2.5 2.5 0 1 1-5 0 2.5 2.5 0 0 1 5 0" />
                  <path d="M0 8s3-5.5 8-5.5S16 8 16 8s-3 5.5-8 5.5S0 8 0 8m8 3.5a3.5 3.5 0 1 0 0-7 3.5 3.5 0 0 0 0 7" />
                </template>
                <template v-else>
                  <path d="M13.359 11.238c.78-.813 1.369-1.814 1.641-2.684C14.671 6.47 11.723 3.5 8 3.5a7.03 7.03 0 0 0-2.078.31l1.423 1.423a3.5 3.5 0 0 1 3.594 3.594l1.42 1.42zM2.12 1.659l12.223 12.222-.708.708L10.89 12.1a7.025 7.025 0 0 1-2.89.6c-3.723 0-6.671-2.97-6.999-5.054.243-1.175 1.168-2.492 2.44-3.493L1.413 2.367l.707-.708z" />
                </template>
              </svg>
            </div>
          </div>

          <!-- Tombol Login -->
          <button
            type="submit"
            class="w-full bg-indigo-600 text-white py-3 rounded-lg font-semibold hover:bg-indigo-700 flex justify-center items-center"
            :disabled="loading"
          >
            <span v-if="loading">Logging in...</span>
            <span v-else>Login</span>
          </button>
        </form>

        <!-- OR -->
        <div class="flex items-center my-6">
          <hr class="flex-grow border-gray-300" />
          <span class="px-4 text-gray-400">Or</span>
          <hr class="flex-grow border-gray-300" />
        </div>

        <!-- Google Login -->
        <button
          class="w-full flex items-center justify-center border py-3 rounded-lg font-semibold text-gray-700 hover:bg-gray-100"
        >
          <img src="@/assets/images/google.png" class="h-5 w-5 mr-2" />
          Continue with Google
        </button>

        <!-- Register Link -->
        <p class="text-center text-gray-600 mt-6">
          Don't have an account?
          <router-link to="/register" class="text-indigo-600 font-semibold">Register</router-link>
        </p>
      </div>
    </div>

    <!-- Image Section -->
    <div class="w-1/2 flex items-center justify-center bg-gray-100 p-8 relative rounded-l-lg">
      <img
        src="@/assets/images/gambar1.jpeg"
        class="w-full h-full object-cover object-center rounded-lg shadow-lg"
        style="max-width: 100%; max-height: 100vh"
      />
      <!-- Teks di atas gambar -->
      <div class="absolute inset-0 flex flex-col justify-end text-white p-8 rounded-lg bg-black bg-opacity-30">
        <h3 class="text-3xl font-bold">Say goodbye to manual scheduling hassles</h3>
        <p class="mt-2 text-lg">
          Our smart appointment booking system allows you to manage your schedule effortlessly.
        </p>
      </div>
    </div>
  </div>
</template>



<style scoped>
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.5s;
}
.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
