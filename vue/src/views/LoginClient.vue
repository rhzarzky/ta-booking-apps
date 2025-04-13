<script>
import { login } from '../../api/auth-api'
import { authServices } from '../../services/auth-services'
import showIcon from '@/assets/images/showps.png'
import hideIcon from '@/assets/images/hideps.png'

export default {
  name: 'LoginClient',
  data() {
    return {
      email: '',
      password: '',
      showPassword: false,
      isSubmitting: false,
      toastMessage: '',
      generalError: '',
      showIcon,
      hideIcon,
    }
  },
  methods: {
    togglePassword() {
      this.showPassword = !this.showPassword
    },

    async handleLogin() {
      this.generalError = ''
      this.toastMessage = ''
      this.isSubmitting = true

      try {
        const payload = {
          email: this.email,
          password: this.password,
        }

        const response = await login(payload)

        if (response.status === 'success' && response.token) {
          authServices.setToken(response.token)
          authServices.setUser(response.user)

          this.toastMessage = 'Login Successful!'
          setTimeout(() => {
            this.toastMessage = ''
          }, 3000)

          setTimeout(() => {
            this.$router.push('/client/dashboard')
          }, 500)
        } else {
          this.generalError = 'Email or password is incorrect.'
        }
      } catch (error) {
        this.generalError = 'Email or password is incorrect.'
        console.error('Login error:', error)
      } finally {
        this.isSubmitting = false
      }
    },
  },
}
</script>

<template>
  <div class="flex h-screen bg-gray-100 relative">
    <!-- Toast Notifikasi -->
    <div
      v-if="toastMessage"
      class="fixed top-5 right-5 bg-green-500 text-white px-4 py-2 rounded shadow-lg z-50 transition-all duration-300"
    >
      {{ toastMessage }}
    </div>

    <!-- Form Login -->
    <div class="w-1/2 flex items-center justify-center p-8">
      <div class="w-full max-w-md">
        <img src="@/assets/images/Appointly.png" alt="Logo Appointly" class="h-10 mb-6" />
        <h2 class="text-3xl font-bold text-gray-800">Welcome Back!</h2>
        <p class="text-gray-500 mb-6">Login to continue to your account.</p>

        <!-- Error umum -->
        <div v-if="generalError" class="mb-4 p-3 bg-red-100 text-red-600 rounded text-sm font-semibold">
          {{ generalError }}
        </div>

        <form @submit.prevent="handleLogin" class="space-y-4 relative">
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

          <div class="relative">
            <label class="block text-gray-700 font-medium">Password</label>
            <input
              :type="showPassword ? 'text' : 'password'"
              v-model="password"
              placeholder="Max. 8 Characters"
              class="w-full px-4 py-3 border rounded-lg focus:ring-2 focus:ring-indigo-400"
              required
            />
            <img
              :src="showPassword ? showIcon : hideIcon  "
              @click="togglePassword"
              class="absolute top-9 right-3 h-5 w-5 cursor-pointer"
              alt="toggle password"
            />
          </div>

          <button
            type="submit"
            class="w-full bg-indigo-600 text-white py-3 rounded-lg font-semibold hover:bg-indigo-700"
            :disabled="isSubmitting"
          >
            {{ isSubmitting ? 'Logging in...' : 'Login' }}
          </button>
        </form>

        <div class="flex items-center my-6">
          <hr class="flex-grow border-gray-300" />
          <span class="px-4 text-gray-400">Or</span>
          <hr class="flex-grow border-gray-300" />
        </div>

        <button
          class="w-full flex items-center justify-center border py-3 rounded-lg font-semibold text-gray-700 hover:bg-gray-100"
        >
          <img src="@/assets/images/google.png" class="h-5 w-5 mr-2" />
          Continue with Google
        </button>

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
      <div class="absolute inset-0 flex flex-col justify-end text-white p-8 rounded-lg bg-black bg-opacity-40">
        <h3 class="text-3xl font-bold">Say goodbye to manual scheduling hassles</h3>
        <p class="mt-2 text-lg">Our smart appointment booking system allows you to manage your schedule effortlessly.</p>
      </div>
    </div>
  </div>
</template>

