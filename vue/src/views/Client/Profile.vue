<script>
import { fetchProfile } from '../../api/auth-api'
import { ref, onMounted } from 'vue'

export default {
  name: 'Profile',
  setup() {
    const user = ref({})

    const getProfile = async () => {
      try {
        const response = await fetchProfile()
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
    editPassword() {
      this.$router.push('/client/change-password')
    }
  }
}
</script>

<template>
  <div class="p-8 bg-gray-100 min-h-screen">

    <!-- Profile Header -->
    <div class="flex items-center space-x-6 mb-8">
      <img
        :src="user.image || `https://ui-avatars.com/api/?name=${user.name || 'User'}`"
        alt="Profile"
        class="w-24 h-24 rounded-full object-cover border-4 border-white shadow"
      />
      <div v-if="user">
        <h1 class="text-2xl font-semibold text-gray-800">{{ user.name }}</h1>
        <p class="text-gray-500">{{ user.email }}</p>
      </div>
    </div>

    <!-- Personal Information -->
    <div class="bg-white p-6 rounded-lg shadow-md mb-8">
      <div class="flex justify-between items-center border-b pb-4 mb-4">
        <h2 class="text-lg font-semibold text-gray-800">Personal Information</h2>
        <button
          @click="editProfile"
          class="flex items-center px-4 py-1 text-sm text-gray-700 border border-gray-300 rounded-full hover:bg-gray-100"
        >
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

    <!-- Security / Password -->
    <div class="bg-white p-6 rounded-lg shadow-md">
      <div class="flex justify-between items-center border-b pb-4 mb-4">
        <h2 class="text-lg font-semibold text-gray-800">Security</h2>
        <button
          @click="editPassword"
          class="flex items-center px-4 py-1 text-sm text-gray-700 border border-gray-300 rounded-full hover:bg-gray-100"
        >
          Edit
        </button>
      </div>

      <div>
        <p class="text-sm text-gray-500">Password</p>
        <p class="text-lg text-gray-700 font-medium">************</p>
      </div>
    </div>
  </div>
</template>

<style scoped>
.pointer {
  cursor: pointer;
}
</style>
