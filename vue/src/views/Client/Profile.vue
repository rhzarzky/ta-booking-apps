<script setup>
import { fetchProfile } from '../../api/auth-api';
import { ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';


const router = useRouter();

const user = ref(null); 
const isLoading = ref(true);
const error = ref(null); 

// Function to fetch user profile
const getProfile = async () => {
  isLoading.value = true; 
  error.value = null; 
  try {
    const response = await fetchProfile();
    user.value = response.user; 
  } catch (err) {
    console.error('Error fetching profile:', err);
    error.value = 'Failed to load profile. Please try again later.'; 
  } finally {
    isLoading.value = false; 
  }
};


onMounted(() => {
  getProfile();
});


const editProfile = () => {
  router.push('/client/edit-profile');
};

const editPassword = () => {
  router.push('/client/change-password');
};
</script>

<template>
  <div class="p-4 sm:p-6 md:p-8 bg-gray-50 min-h-screen">
    <div v-if="isLoading" class="flex justify-center items-center h-96">
      <div class="animate-spin rounded-full h-12 w-12 border-4 border-indigo-500 border-t-transparent"></div>
      <p class="ml-4 text-gray-600">Loading profile data...</p>
    </div>

    <div v-else-if="error" class="text-center text-red-600 p-8 bg-red-50 rounded-lg shadow-sm max-w-lg mx-auto">
      <p class="text-lg font-medium">{{ error }}</p>
      <p class="text-sm text-red-500 mt-2">Please check your internet connection or refresh the page.</p>
      <button @click="getProfile" class="mt-4 px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700 transition">
        Retry
      </button>
    </div>

    <div v-else-if="user" class="max-w-4xl mx-auto bg-white rounded-2xl shadow-xl p-6 sm:p-8">
      <div class="flex flex-col sm:flex-row items-center sm:space-x-6 mb-8 pb-6 border-b border-gray-200">
        <img
          :src="user.image || `https://ui-avatars.com/api/?name=${user.name || 'User'}&background=random&color=fff&size=96`"
          :alt="user.name || 'User Profile'"
          class="w-28 h-28 rounded-full object-cover border-4 border-white shadow-lg flex-shrink-0 mb-4 sm:mb-0"
        />
        <div>
          <h1 class="text-3xl font-extrabold text-gray-900 mb-1">{{ user.name || 'Guest User' }}</h1>
          <p class="text-gray-600 text-lg">{{ user.email || 'No email available' }}</p>
        </div>
      </div>

      <div class="bg-white p-6 rounded-lg shadow-md mb-8 border border-gray-100">
        <div class="flex justify-between items-center pb-4 mb-4">
          <h2 class="text-xl font-bold text-gray-800">Personal Information</h2>
          <button
            @click="editProfile"
            class="flex items-center px-5 py-2 text-sm text-indigo-600 border border-indigo-300 rounded-full hover:bg-indigo-50 transition duration-200 ease-in-out focus:outline-none focus:ring-2 focus:ring-indigo-500"
          >
            <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z" />
            </svg>
            Edit Profile
          </button>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-y-6 gap-x-8">
          <div>
            <p class="text-sm text-gray-500 mb-1">Full Name</p>
            <p class="text-lg text-gray-800 font-semibold">{{ user.name || '-' }}</p>
          </div>

          <div>
            <p class="text-sm text-gray-500 mb-1">Email</p>
            <p class="text-lg text-gray-800 font-semibold">{{ user.email || '-' }}</p>
          </div>

          <div>
            <p class="text-sm text-gray-500 mb-1">Status</p>
            <p class="text-lg text-gray-800 font-semibold">{{ user.status || '-' }}</p>
          </div>
          </div>
      </div>

      <div class="bg-white p-6 rounded-lg shadow-md border border-gray-100">
        <div class="flex justify-between items-center pb-4 mb-4">
          <h2 class="text-xl font-bold text-gray-800">Security</h2>
          <button
            @click="editPassword"
            class="flex items-center px-5 py-2 text-sm text-indigo-600 border border-indigo-300 rounded-full hover:bg-indigo-50 transition duration-200 ease-in-out focus:outline-none focus:ring-2 focus:ring-indigo-500"
          >
            <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z" />
            </svg>
            Change Password
          </button>
        </div>

        <div>
          <p class="text-sm text-gray-500 mb-1">Password</p>
          <p class="text-lg text-gray-800 font-semibold">************</p>
        </div>
      </div>
    </div>

    <div v-else class="text-center text-gray-500 p-8 max-w-lg mx-auto bg-white rounded-lg shadow-sm">
      <p class="text-lg">No user data found.</p>
      <p class="text-sm mt-2">Could not retrieve your profile. Please ensure you are logged in.</p>
    </div>
  </div>
</template>
