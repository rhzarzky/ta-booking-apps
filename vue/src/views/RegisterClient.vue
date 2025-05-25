<template>
  <div class="flex h-screen bg-gray-100">
    <!-- Form Section -->
    <div class="w-1/2 flex items-center justify-center p-8">
      <div class="w-full max-w-lg">
        <img src="@/assets/images/Appointly.png" alt="Logo Appointly" class="h-10 mb-6" />

        <h2 class="text-3xl font-bold text-gray-800">Unlock Your Experience!</h2>
        <p class="text-gray-500 mb-6">Create an account and unlock your next great scheduling.</p>

        <!-- Error -->
        <div v-if="errorMessage" class="bg-red-100 text-red-700 px-4 py-3 rounded mb-4">
          {{ errorMessage }}
        </div>

        <form @submit.prevent="handleRegister" class="space-y-4">
          <div>
            <label class="block text-gray-700 font-medium">Full Name</label>
            <input
              type="text"
              v-model="name"
              class="w-full px-4 py-3 border rounded-lg focus:ring-2 focus:ring-indigo-400"
              placeholder="John Doe"
              required
            />
          </div>
          <div>
            <label class="block text-gray-700 font-medium">Email</label>
            <input
              type="email"
              v-model="email"
              class="w-full px-4 py-3 border rounded-lg focus:ring-2 focus:ring-indigo-400"
              placeholder="johndoe@gmail.com"
              required
            />
          </div>
          <div>
            <label class="block text-gray-700 font-medium">Password</label>
            <div class="relative">
              <input
                :type="showPassword ? 'text' : 'password'"
                v-model="password"
                class="w-full px-4 py-3 border rounded-lg focus:ring-2 focus:ring-indigo-400"
                placeholder="Min. 8 Characters"
                required
              />
              <svg
                @click="showPassword = !showPassword"
                xmlns="http://www.w3.org/2000/svg"
                width="20"
                height="20"
                fill="currentColor"
                class="absolute right-4 top-1/2 transform -translate-y-1/2 text-gray-500 cursor-pointer"
                viewBox="0 0 16 16"
              >
                <path
                  v-if="!showPassword"
                  d="M0 8s3-5.5 8-5.5S16 8 16 8s-3 5.5-8 5.5S0 8 0 8m8 3.5a3.5 3.5 0 1 0 0-7 3.5 3.5 0 0 0 0 7"
                />
                <path
                  v-else
                  d="M13.359 11.238c.78-.813 1.369-1.814 1.641-2.684..."
                />
              </svg>
            </div>
          </div>
          <div>
            <label class="block text-gray-700 font-medium">Confirm Password</label>
            <div class="relative">
              <input
                :type="showConfirmPassword ? 'text' : 'password'"
                v-model="confirmPassword"
                class="w-full px-4 py-3 border rounded-lg focus:ring-2 focus:ring-indigo-400"
                placeholder="Confirm your password"
                required
              />
              <svg
                @click="showConfirmPassword = !showConfirmPassword"
                xmlns="http://www.w3.org/2000/svg"
                width="20"
                height="20"
                fill="currentColor"
                class="absolute right-4 top-1/2 transform -translate-y-1/2 text-gray-500 cursor-pointer"
                viewBox="0 0 16 16"
              >
                <path
                  v-if="!showConfirmPassword"
                  d="M0 8s3-5.5 8-5.5S16 8 16 8s-3 5.5-8 5.5S0 8 0 8m8 3.5a3.5 3.5 0 1 0 0-7 3.5 3.5 0 0 0 0 7"
                />
                <path
                  v-else
                  d="M13.359 11.238c.78-.813 1.369-1.814 1.641-2.684..."
                />
              </svg>
            </div>
          </div>

          <button
            type="submit"
            class="w-full bg-indigo-600 text-white py-3 rounded-lg font-semibold hover:bg-indigo-700 flex items-center justify-center"
            :disabled="isLoading"
          >
            <span v-if="isLoading" class="loader mr-2"></span>
            {{ isLoading ? 'Registering...' : 'Get Started' }}
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

        <!-- Login Link -->
        <p class="text-center text-gray-600 mt-6">
          Already have an account?
          <router-link to="/login" class="text-indigo-600 font-semibold">Sign in</router-link>
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
      <div class="absolute inset-0 flex flex-col justify-end text-white p-8 rounded-lg">
        <h3 class="text-3xl font-bold">Say goodbye to manual scheduling hassles</h3>
        <p class="mt-2 text-lg">
          Our smart appointment booking system allows you to manage your schedule effortlessly.
        </p>
      </div>
    </div>
  </div>
</template>

<script>
import Swal from 'sweetalert2'
import { register } from '@/api/auth-api'

export default {
  name: 'RegisterClient',
  data() {
    return {
      name: '',
      email: '',
      password: '',
      confirmPassword: '',
      showPassword: false,
      showConfirmPassword: false,
      errorMessage: '',
      isLoading: false,
    }
  },
  methods: {
    async handleRegister() {
      this.errorMessage = ''
      if (this.password.length < 8) {
        this.errorMessage = 'Password must be at least 8 characters long.'
        return
      }

      if (this.password !== this.confirmPassword) {
        this.errorMessage = 'Passwords do not match.'
        return
      }

      const userData = {
        name: this.name,
        email: this.email,
        password: this.password,
        password_confirmation: this.confirmPassword,
      }

      try {
        this.isLoading = true
        const response = await register(userData)

        if (response.status === 'success') {
          this.$router.push({ path: '/verify-email', query: { email: this.email } })
        }
      } catch (error) {
        if (error.response?.data?.errors?.email) {
          this.errorMessage = error.response.data.errors.email[0]
        } else if (error.response?.data?.message) {
          this.errorMessage = error.response.data.message
        } else {
          this.errorMessage = 'Something went wrong. Please try again.'
        }
      } finally {
        this.isLoading = false
      }
    },
  },
}
</script>

<style scoped>
.loader {
  border: 3px solid #f3f3f3;
  border-top: 3px solid white;
  border-radius: 50%;
  width: 18px;
  height: 18px;
  animation: spin 0.8s linear infinite;
}
@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}
</style>
