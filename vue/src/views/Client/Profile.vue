<script>
import { fetchProfile } from '../../../api/auth-api'
import { ref, onMounted } from 'vue'

export default {
  name: 'Profile',
  setup() {
    const user = ref({})

    const getProfile = async () => {
      try {
        const response = await fetchProfile()
        console.log('Profile data:', response) // CEK RESPONSE
        user.value = response.user
      } catch (error) {
        console.error('Error fetching profile:', error)
      }
    }

    onMounted(() => {
      getProfile()
    })

    return {
      user
    }
  },
  methods: {
    editProfile() {
      this.$router.push('/client/edit-profile')
    },
  }
}
</script>


<template>
  <div class="p-8 bg-gray-100 min-h-screen">
    <!-- Profile Header -->
    <div class="flex items-center space-x-6 mb-8">
      <img
        src="https://randomuser.me/api/portraits/women/44.jpg"
        alt="Profile"
        class="w-24 h-24 rounded-full object-cover border-4 border-white shadow"
      />
      <div v-if="user">
        <h1 class="text-2xl font-semibold text-gray-800">{{ user.name }}</h1>
        <p class="text-gray-500">{{ user.email }}</p>
      </div>
    </div>

    <!-- Personal Information -->
    <div class="bg-white p-6 rounded-lg shadow-md">
      <div class="flex justify-between items-center border-b pb-4 mb-4">
        <h2 class="text-lg font-semibold text-gray-800">Personal Information</h2>
        <button
          @click="editProfile"
          class="flex items-center px-4 py-1 text-sm text-gray-700 border border-gray-300 rounded-full hover:bg-gray-100"
        >
          <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" d="M11 5h2M12 12v.01M12 17h.01M5 20h14a2 2 0 002-2V6a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
          </svg>
          Edit
        </button>
      </div>

      <div class="space-y-4">
        <div>
          <p class="text-sm text-gray-500">Full Name</p>
          <p class="text-lg text-gray-700 font-medium">{{ user?.name || '-' }}</p>
        </div>

        <div>
          <p class="text-sm text-gray-500">Email</p>
          <p class="text-lg text-gray-700 font-medium">{{ user?.email || '-' }}</p>
        </div>

        <div>
          <p class="text-sm text-gray-500">Status</p>
          <p class="text-lg text-gray-700 font-medium">{{ user?.status || '-' }}</p>
        </div>
      </div>
    </div>
  </div>
</template>

