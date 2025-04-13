<script>
import Swal from 'sweetalert2'
import { RegisterClient } from '../../api/auth-api'
import showIcon from '@/assets/images/showps.png'
import hideIcon from '@/assets/images/hideps.png'

export default {
  name: 'RegisterClient',
  data() {
    return {
      name: '',
      email: '',
      password: '',
      confirmPassword: '',
      errors: {},
      generalError: '',
      isSubmitting: false,
      showPassword: false,
      showConfirmPassword: false,
      icons: {
        show: showIcon,
        hide: hideIcon,
      },
    }
  },
  methods: {
    togglePassword() {
      this.showPassword = !this.showPassword
    },
    toggleConfirmPassword() {
      this.showConfirmPassword = !this.showConfirmPassword
    },
    async handleRegister() {
      this.errors = {}
      this.generalError = ''
      this.isSubmitting = true

      // Validasi confirm password setelah klik submit
      if (this.password !== this.confirmPassword) {
        this.errors.confirmPassword = 'Confirmation password does not match'
      }

      try {
        const payload = {
          name: this.name,
          email: this.email,
          password: this.password,
          password_confirmation: this.confirmPassword,
        }

        const response = await RegisterClient(payload)

        if (response.token) {
          await Swal.fire({
            icon: 'success',
            title: 'Registered!',
            text: 'Your account has been created successfully.',
            timer: 2000,
            showConfirmButton: false,
          })
          this.$router.push('/login')
        } else {
          const errorObj = response.errors || {}
          this.errors.email = errorObj.email?.[0] || ''
          const passwordError = errorObj.password?.[0] || ''
          if (passwordError !== 'The password field confirmation does not match.') {
            this.errors.password = passwordError
          }
          this.errors.name = errorObj.name?.[0] || ''
        }
      } catch (err) {
        const errorObj = err.response?.data?.errors || {}
        this.errors.email = errorObj.email?.[0] || ''
        const passwordError = errorObj.password?.[0] || ''
        if (passwordError !== 'The password field confirmation does not match.') {
          this.errors.password = passwordError
        }
        this.errors.name = errorObj.name?.[0] || ''
      } finally {
        this.isSubmitting = false
      }
    },
  },
}
</script>

<template>
  <div class="flex h-screen bg-gray-100">
    <!-- Form Section -->
    <div class="w-1/2 flex items-center justify-center p-8">
      <div class="w-full max-w-lg">
        <img src="@/assets/images/Appointly.png" alt="Logo Appointly" class="h-10 mb-6" />
        <h2 class="text-3xl font-bold text-gray-800">Unlock Your Experience!</h2>
        <p class="text-gray-500 mb-6">Create an account and unlock your next great scheduling.</p>

        <!-- Error Summary -->
        <!-- Error Summary -->
        <div
          v-if="errors.email || errors.password || errors.confirmPassword"
          class="mb-4 p-3 bg-red-100 text-red-600 rounded text-sm font-semibold"
        >
          <p v-if="errors.email">{{ errors.email }}</p>
          <p v-if="errors.password">{{ errors.password }}</p>
          <p v-if="errors.confirmPassword">{{ errors.confirmPassword }}</p>
        </div>

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
            <p v-if="errors.name" class="text-red-500 text-sm">{{ errors.name }}</p>
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

          <div class="relative">
            <label class="block text-gray-700 font-medium">Password</label>
            <input
              :type="showPassword ? 'text' : 'password'"
              v-model="password"
              placeholder="Minimum 8 characters"
              class="w-full px-4 py-3 border rounded-lg focus:ring-2 focus:ring-indigo-400"
              required
            />
            <img
              :src="showPassword ? icons.show : icons.hide"
              @click="togglePassword"
              class="absolute right-4 top-11 h-5 w-5 cursor-pointer"
              alt="Toggle Password"
            />
          </div>

          <div class="relative">
            <label class="block text-gray-700 font-medium">Confirm Password</label>
            <input
              :type="showConfirmPassword ? 'text' : 'password'"
              v-model="confirmPassword"
              placeholder="Confirm your password"
              class="w-full px-4 py-3 border rounded-lg focus:ring-2 focus:ring-indigo-400"
              required
            />
            <img
              :src="showConfirmPassword ? icons.show : icons.hide"
              @click="toggleConfirmPassword"
              class="absolute right-4 top-11 h-5 w-5 cursor-pointer"
              alt="Toggle Confirm Password"
            />
          </div>

          <button
            type="submit"
            class="w-full bg-indigo-600 text-white py-3 rounded-lg font-semibold hover:bg-indigo-700"
            :disabled="isSubmitting"
          >
            {{ isSubmitting ? 'Processing...' : 'Get Started' }}
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
          Already have an account?
          <router-link to="/login" class="text-indigo-600 font-semibold">Sign in</router-link>
        </p>
      </div>
    </div>

    <!-- Right Image Section -->
    <div class="w-1/2 flex items-center justify-center bg-gray-100 p-8 relative rounded-l-lg">
      <img
        src="@/assets/images/gambar1.jpeg"
        class="w-full h-full object-cover object-center rounded-lg shadow-lg"
        style="max-width: 100%; max-height: 100vh"
      />
      <div
        class="absolute inset-0 flex flex-col justify-end text-white p-8 rounded-lg bg-black bg-opacity-40"
      >
        <h3 class="text-3xl font-bold">Say goodbye to manual scheduling hassles</h3>
        <p class="mt-2 text-lg">
          Our smart appointment booking system allows you to manage your schedule effortlessly.
        </p>
      </div>
    </div>
  </div>
</template>
