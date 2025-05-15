<template>
  <div class="p-4 sm:p-8 max-w-2xl mx-auto">
    <div class="mb-6">
      <h1 class="text-2xl font-bold text-gray-800">Change Password</h1>
      <p class="text-sm text-gray-500 mt-1">
        <router-link to="/client/dashboard" class="hover:underline">Dashboard</router-link> /
        <router-link to="/client/profile" class="hover:underline">Profile</router-link> /
        <span class="text-indigo-600">Change Password</span>
      </p>
    </div>

    <div class="bg-white shadow-lg rounded-xl p-6 sm:p-10">
      <form @submit.prevent="handleSubmit" class="space-y-6">

        <!-- Current Password -->
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Current Password</label>
          <div class="relative">
            <input
              :type="showCurrent ? 'text' : 'password'"
              v-model="form.current_password"
              class="w-full px-4 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-400"
              required
            />
            <button
              type="button"
              class="absolute right-3 top-2.5 text-sm text-gray-500"
              @click="showCurrent = !showCurrent"
            >
              {{ showCurrent ? 'Hide' : 'Show' }}
            </button>
          </div>
        </div>

        <!-- New Password -->
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">New Password</label>
          <div class="relative">
            <input
              :type="showNew ? 'text' : 'password'"
              v-model="form.password"
              class="w-full px-4 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-400"
              required
            />
            <button
              type="button"
              class="absolute right-3 top-2.5 text-sm text-gray-500"
              @click="showNew = !showNew"
            >
              {{ showNew ? 'Hide' : 'Show' }}
            </button>
          </div>
        </div>

        <!-- Confirm New Password -->
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Confirm New Password</label>
          <div class="relative">
            <input
              :type="showConfirm ? 'text' : 'password'"
              v-model="form.password_confirmation"
              class="w-full px-4 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-400"
              required
            />
            <button
              type="button"
              class="absolute right-3 top-2.5 text-sm text-gray-500"
              @click="showConfirm = !showConfirm"
            >
              {{ showConfirm ? 'Hide' : 'Show' }}
            </button>
          </div>
        </div>

        <!-- Buttons -->
        <div class="flex justify-end gap-4 pt-4">
          <button
            type="button"
            @click="router.push('/client/profile')"
            class="px-6 py-2 rounded-md border border-gray-300 text-gray-700 hover:bg-gray-100 transition"
          >
            Cancel
          </button>
          <button
            type="submit"
            class="px-6 py-2 rounded-md bg-blue-600 text-white font-medium hover:bg-blue-700 transition"
          >
            Update Password
          </button>
        </div>

      </form>
    </div>
  </div>
</template>

<script setup>
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { ref } from 'vue'

const router = useRouter()
const auth = useAuthStore()

const form = ref({
  current_password: '',
  password: '',
  password_confirmation: '',
})

const showCurrent = ref(false)
const showNew = ref(false)
const showConfirm = ref(false)

const handleSubmit = async () => {
  if (form.value.password !== form.value.password_confirmation) {
    alert('New password and confirmation do not match.')
    return
  }

  const formData = new FormData()
  formData.append('_method', 'PUT')
  formData.append('current_password', form.value.current_password)
  formData.append('password', form.value.password)
  formData.append('password_confirmation', form.value.password_confirmation)

  try {
    await auth.updateProfile(formData)
    alert('Password updated successfully!')
    router.push('/client/profile')
  } catch (error) {
    alert('Failed to update password. Please ensure current password is correct.')
    console.error(error)
  }
}
</script>
