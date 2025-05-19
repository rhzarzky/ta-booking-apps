<template>
  <div class="p-6 max-w-2xl mx-auto">
    <h2 class="text-2xl font-bold mb-4 text-gray-800">Change Password</h2>

    <form @submit.prevent="handleSubmit" class="space-y-5">

      <!-- Current Password -->
      <div>
        <label class="block text-sm font-medium text-gray-700">Current Password</label>
        <div class="relative">
          <input
            :type="showCurrent ? 'text' : 'password'"
            v-model="form.current_password"
            class="w-full px-4 py-2 border rounded-md focus:outline-none focus:ring-2"
            :class="errors.current_password ? 'border-red-500 focus:ring-red-300' : 'border-gray-300 focus:ring-blue-300'"
          />
          <button type="button" @click="showCurrent = !showCurrent" class="absolute right-3 top-2.5 text-sm text-gray-500">
            {{ showCurrent ? 'Hide' : 'Show' }}
          </button>
        </div>
        <p v-if="errors.current_password" class="text-sm text-red-500 mt-1">
          {{ errors.current_password }}
        </p>
      </div>

      <!-- New Password -->
      <div>
        <label class="block text-sm font-medium text-gray-700">New Password</label>
        <div class="relative">
          <input
            :type="showNew ? 'text' : 'password'"
            v-model="form.password"
            class="w-full px-4 py-2 border rounded-md focus:outline-none focus:ring-2"
            :class="errors.password ? 'border-red-500 focus:ring-red-300' : 'border-gray-300 focus:ring-blue-300'"
          />
          <button type="button" @click="showNew = !showNew" class="absolute right-3 top-2.5 text-sm text-gray-500">
            {{ showNew ? 'Hide' : 'Show' }}
          </button>
        </div>
        <p v-if="errors.password" class="text-sm text-red-500 mt-1">
          {{ errors.password }}
        </p>
      </div>

      <!-- Confirm New Password -->
      <div>
        <label class="block text-sm font-medium text-gray-700">Confirm New Password</label>
        <div class="relative">
          <input
            :type="showConfirm ? 'text' : 'password'"
            v-model="form.password_confirmation"
            class="w-full px-4 py-2 border rounded-md focus:outline-none focus:ring-2"
            :class="errors.password_confirmation ? 'border-red-500 focus:ring-red-300' : 'border-gray-300 focus:ring-blue-300'"
          />
          <button type="button" @click="showConfirm = !showConfirm" class="absolute right-3 top-2.5 text-sm text-gray-500">
            {{ showConfirm ? 'Hide' : 'Show' }}
          </button>
        </div>
        <p v-if="errors.password_confirmation" class="text-sm text-red-500 mt-1">
          {{ errors.password_confirmation }}
        </p>
      </div>

      <!-- Submit -->
      <div class="flex justify-end gap-4 pt-4">
        <button type="button" @click="router.push('/client/profile')"
          class="px-6 py-2 border rounded-md text-gray-700 hover:bg-gray-100">
          Cancel
        </button>
        <button type="submit"
          class="px-6 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition">
          Update Password
        </button>
      </div>
    </form>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

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

const errors = ref({
  current_password: '',
  password: '',
  password_confirmation: ''
})

const handleSubmit = async () => {
  errors.value = {
    current_password: '',
    password: '',
    password_confirmation: ''
  }

  if (!form.value.current_password) {
    errors.value.current_password = 'Current password is required.'
  }

  if (form.value.password.length < 6) {
    errors.value.password = 'Password must be at least 6 characters.'
  }

  if (form.value.password !== form.value.password_confirmation) {
    errors.value.password_confirmation = 'Passwords do not match.'
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
    const msg = error?.response?.data?.message || ''
    if (msg.includes('current password')) {
      errors.value.current_password = 'Current password is incorrect.'
    } else {
      alert('Failed to update password.')
    }
  }
}
</script>
