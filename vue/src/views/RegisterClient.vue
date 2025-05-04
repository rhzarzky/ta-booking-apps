<template>
  <div class="flex h-screen bg-gray-100">
    <!-- Form Register -->
    <div class="w-1/2 flex items-center justify-center p-8">
      <div class="w-full max-w-lg">
        <!-- Logo -->
        <img src="@/assets/images/Appointly.png" alt="Logo Appointly" class="h-10 mb-6" />

        <h2 class="text-3xl font-bold text-gray-800">Unlock Your Experience!</h2>
        <p class="text-gray-500 mb-6">Create an account and unlock your next great scheduling.</p>

        <!-- Error Notification -->
        <div v-if="errorMessage" class="bg-red-100 text-red-700 px-4 py-3 rounded mb-4">
          {{ errorMessage }}
        </div>

        <!-- Form -->
        <form @submit.prevent="handleRegister" class="space-y-4">
          <div>
            <label class="block text-gray-700 font-medium">Full Name</label>
            <input
              type="text"
              v-model="name"
              placeholder="John Doe"
              class="w-full px-4 py-3 border rounded-lg focus:ring-2 focus:ring-indigo-400"
              required
            />
          </div>
          <div>
            <label class="block text-gray-700 font-medium">Email</label>
            <input
              type="email"
              v-model="email"
              placeholder="johndoe@gmail.com"
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
                placeholder="Min. 8 Characters"
                class="w-full px-4 py-3 border rounded-lg focus:ring-2 focus:ring-indigo-400"
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
                <template v-if="!showPassword">
                  <path d="M10.5 8a2.5 2.5 0 1 1-5 0 2.5 2.5 0 0 1 5 0" />
                  <path
                    d="M0 8s3-5.5 8-5.5S16 8 16 8s-3 5.5-8 5.5S0 8 0 8m8 3.5a3.5 3.5 0 1 0 0-7 3.5 3.5 0 0 0 0 7"
                  />
                </template>
                <template v-else>
                  <path
                    d="M13.359 11.238c.78-.813 1.369-1.814 1.641-2.684..."
                  />
                </template>
              </svg>
            </div>
          </div>
          <div>
            <label class="block text-gray-700 font-medium">Confirm Password</label>
            <div class="relative">
              <input
                :type="showConfirmPassword ? 'text' : 'password'"
                v-model="confirmPassword"
                placeholder="Confirm your password"
                class="w-full px-4 py-3 border rounded-lg focus:ring-2 focus:ring-indigo-400"
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
                <template v-if="!showConfirmPassword">
                  <path d="M10.5 8a2.5 2.5 0 1 1-5 0..." />
                </template>
                <template v-else>
                  <path d="M13.359 11.238c.78-.813 1.369-1.814 1.641-2.684..." />
                </template>
              </svg>
            </div>
          </div>
          <button
            type="submit"
            class="w-full bg-indigo-600 text-white py-3 rounded-lg font-semibold hover:bg-indigo-700"
          >
            Get Started
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
      errorMessage: '', // Buat nampung error di atas form
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
        const response = await register(userData)

        if (response.status === 'success') {
          await Swal.fire({
            icon: 'success',
            title: 'Account Created Successfully!',
            text: 'Your account has been created. Please login to continue.',
            timer: 2000,
            showConfirmButton: false,
          })
          this.$router.push('/login')
        }
      } catch (error) {
        console.error('Registration error:', error)

        if (error.response && error.response.data) {
          const resData = error.response.data

          if (resData.errors && resData.errors.email && resData.errors.email[0]) {
            this.errorMessage = 'The email is already registered. Please use a different email.'
          } else if (resData.message) {
            this.errorMessage = resData.message
          } else {
            this.errorMessage = 'An error occurred. Please try again later.'
          }
        } else {
          this.errorMessage = 'An error occurred. Please try again later.'
        }
      }
    },
  },
}
</script>
