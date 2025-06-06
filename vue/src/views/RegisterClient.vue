<script>
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
      errorMessage: '', // Untuk pesan error umum (termasuk dari backend)
      localErrors: { // Untuk pesan error validasi client-side spesifik per field
        name: '',
        email: '',
        password: '',
        confirmPassword: '',
      },
      isLoading: false,
      formSubmitted: false, // Flag untuk menandakan form sudah pernah disubmit
    }
  },
  computed: {
    // Computed properties untuk validasi password (digunakan untuk logika, bukan tampilan real-time langsung)
    passwordLengthValid() {
      return this.password.length >= 8
    },
    passwordHasUppercase() {
      return /[A-Z]/.test(this.password)
    },
    passwordHasLowercase() {
      return /[a-z]/.test(this.password)
    },
    passwordHasNumber() {
      return /\d/.test(this.password)
    },
    passwordHasSpecialChar() {
      // Regex yang sama dengan backend Laravel Anda
      return /[@$!%*#?&^]/.test(this.password)
    },
    passwordsMatch() {
      return this.password === this.confirmPassword && this.confirmPassword !== ''
    },
    // Menentukan apakah semua kriteria password sudah terpenuhi
    allPasswordCriteriaMet() {
      return (
        this.passwordLengthValid &&
        this.passwordHasUppercase &&
        this.passwordHasLowercase &&
        this.passwordHasNumber &&
        this.passwordHasSpecialChar
      )
    },
  },
  methods: {
    validateForm() {
      // Reset semua error lokal
      this.localErrors = {
        name: '',
        email: '',
        password: '',
        confirmPassword: '',
      }
      this.errorMessage = '' // Hapus pesan error umum sebelumnya

      let isValid = true

      // Validasi Nama
      if (!this.name) {
        this.localErrors.name = 'Full Name is required.'
        isValid = false
      } else if (this.name.length > 255) {
        this.localErrors.name = 'Full Name cannot exceed 255 characters.'
        isValid = false
      }

      // Validasi Email
      if (!this.email) {
        this.localErrors.email = 'Email is required.'
        isValid = false
      } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(this.email)) {
        this.localErrors.email = 'Please enter a valid email address.'
        isValid = false
      } else if (this.email.length > 255) {
        this.localErrors.email = 'Email cannot exceed 255 characters.'
        isValid = false
      }

      // Validasi Password
      if (!this.password) {
        this.localErrors.password = 'Password is required.'
        isValid = false
      } else if (!this.allPasswordCriteriaMet) {
        // Pesan ini akan muncul di bawah input password
        this.localErrors.password = 'Password does not meet all requirements. See checklist below.'
        isValid = false
      }

      // Validasi Konfirmasi Password
      if (!this.confirmPassword) {
        this.localErrors.confirmPassword = 'Confirm Password is required.'
        isValid = false
      } else if (this.password !== this.confirmPassword) {
        this.localErrors.confirmPassword = 'Passwords do not match.'
        isValid = false
      }

      return isValid
    },

    async handleRegister() {
      this.formSubmitted = true // Set flag bahwa form sudah pernah disubmit
      this.errorMessage = '' // Hapus pesan error umum sebelumnya

      // Lakukan validasi lokal saat tombol diklik
      if (!this.validateForm()) {
        return // Hentikan proses jika validasi gagal
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
          sessionStorage.setItem('verify-email', this.email)
          this.$router.push({ path: '/verify-email' })
        }
      } catch (error) {
        // Penanganan error dari backend (seperti 422 Unprocessable Content)
        if (error.response?.data?.errors) {
            let backendErrors = error.response.data.errors;
            // Bersihkan error lokal sebelumnya sebelum menampilkan error backend
            this.localErrors = { name: '', email: '', password: '', confirmPassword: '' };
            this.errorMessage = 'Please fix the following errors:'; // Pesan umum untuk pengguna

            for (const key in backendErrors) {
                if (backendErrors.hasOwnProperty(key)) {
                    // Petakan kunci error backend ke kunci localErrors frontend
                    if (this.localErrors.hasOwnProperty(key)) {
                        this.localErrors[key] = backendErrors[key][0]; // Ambil pesan error pertama
                    } else {
                        // Untuk error backend umum yang tidak terikat pada field tertentu,
                        // tambahkan ke errorMessage umum
                        this.errorMessage += `\n- ${backendErrors[key][0]}`;
                    }
                }
            }
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
.error-message {
  color: red;
  font-size: 0.875rem; /* text-sm */
  margin-top: 0.25rem; /* mt-1 */
}
</style>

<template>
  <div class="flex flex-col md:flex-row h-screen bg-gray-100">
    <div class="w-full md:w-1/2 flex items-center justify-center p-8">
      <div class="w-full max-w-lg">
        <img src="@/assets/images/Appointly.png" alt="Logo Appointly" class="h-10 mb-6 mx-auto md:mx-0" />

        <h2 class="text-3xl font-bold text-gray-800 text-center md:text-left">Unlock Your Experience!</h2>
        <p class="text-gray-500 mb-6 text-center md:text-left">Create an account and unlock your next great scheduling.</p>

        <div v-if="errorMessage" class="bg-red-100 text-red-700 px-4 py-3 rounded mb-4 text-center">
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
              @input="formSubmitted = false" />
            <p v-if="formSubmitted && localErrors.name" class="error-message">{{ localErrors.name }}</p>
          </div>
          <div>
            <label class="block text-gray-700 font-medium">Email</label>
            <input
              type="email"
              v-model="email"
              class="w-full px-4 py-3 border rounded-lg focus:ring-2 focus:ring-indigo-400"
              placeholder="johndoe@gmail.com"
              required
              @input="formSubmitted = false" />
            <p v-if="formSubmitted && localErrors.email" class="error-message">{{ localErrors.email }}</p>
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
                @input="formSubmitted = false" />
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
                  d="M13.359 11.238c.78-.813 1.369-1.814 1.641-2.684C14.671 6.47 11.723 3.5 8 3.5a7.03 7.03 0 0 0-2.078.31l1.423 1.423a3.5 3.5 0 0 1 3.594 3.594l1.42 1.42zM2.12 1.659l12.223 12.222-.708.708L10.89 12.1a7.025 7.025 0 0 1-2.89.6c-3.723 0-6.671-2.97-6.999-5.054.243-1.175 1.168-2.492 2.44-3.493L1.413 2.367l.707-.708z"
                />
              </svg>
            </div>
            <p v-if="formSubmitted && localErrors.password" class="error-message">{{ localErrors.password }}</p>

            <ul v-if="formSubmitted && !allPasswordCriteriaMet" class="text-sm text-gray-600 mt-2 space-y-1">
              <li :class="{ 'text-green-600': passwordLengthValid, 'text-red-500': !passwordLengthValid }">
                <span v-if="passwordLengthValid">&#10003;</span>
                <span v-else>&#10007;</span>
                Minimum 8 characters
              </li>
              <li :class="{ 'text-green-600': passwordHasUppercase, 'text-red-500': !passwordHasUppercase }">
                <span v-if="passwordHasUppercase">&#10003;</span>
                <span v-else>&#10007;</span>
                At least one uppercase letter (A-Z)
              </li>
              <li :class="{ 'text-green-600': passwordHasLowercase, 'text-red-500': !passwordHasLowercase }">
                <span v-if="passwordHasLowercase">&#10003;</span>
                <span v-else>&#10007;</span>
                At least one lowercase letter (a-z)
              </li>
              <li :class="{ 'text-green-600': passwordHasNumber, 'text-red-500': !passwordHasNumber }">
                <span v-if="passwordHasNumber">&#10003;</span>
                <span v-else>&#10007;</span>
                At least one number (0-9)
              </li>
              <li :class="{ 'text-green-600': passwordHasSpecialChar, 'text-red-500': !passwordHasSpecialChar }">
                <span v-if="passwordHasSpecialChar">&#10003;</span>
                <span v-else>&#10007;</span>
                At least one special character (@$!%*#?&^)
              </li>
            </ul>
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
                @input="formSubmitted = false" />
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
                  d="M13.359 11.238c.78-.813 1.369-1.814 1.641-2.684C14.671 6.47 11.723 3.5 8 3.5a7.03 7.03 0 0 0-2.078.31l1.423 1.423a3.5 3.5 0 0 1 3.594 3.594l1.42 1.42zM2.12 1.659l12.223 12.222-.708.708L10.89 12.1a7.025 7.025 0 0 1-2.89.6c-3.723 0-6.671-2.97-6.999-5.054.243-1.175 1.168-2.492 2.44-3.493L1.413 2.367l.707-.708z"
                />
              </svg>
            </div>
            <p
              :class="{ 'text-green-600': passwordsMatch, 'text-red-500': !passwordsMatch }"
              class="text-sm mt-1"
              v-if="formSubmitted && password.length > 0 && confirmPassword.length > 0 && !passwordsMatch"
            >
              <span v-if="passwordsMatch">&#10003;</span>
              <span v-else>&#10007;</span>
              Passwords do not match.
            </p>
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

        <p class="text-center text-gray-600 mt-2">
          Already have an account?
          <router-link to="/login" class="text-indigo-600 font-semibold">Sign in</router-link>
        </p>
      </div>
    </div>

    <div class="hidden md:flex w-full md:w-1/2 items-center justify-center bg-gray-100 p-8 relative rounded-l-lg">
      <img
        src="@/assets/images/gambar1.jpeg"
        class="w-full h-full object-cover object-center rounded-lg shadow-lg"
        style="max-width: 100%; max-height: 100vh"
      />
      <div class="absolute inset-0 flex flex-col justify-end text-white p-8 rounded-lg bg-black bg-opacity-30">
        <h3 class="text-3xl font-bold">Say goodbye to manual scheduling hassles</h3>
        <p class="mt-2 text-lg">
          Our smart appointment booking system allows you to manage your schedule effortlessly.
        </p>
      </div>
    </div>
  </div>
</template>