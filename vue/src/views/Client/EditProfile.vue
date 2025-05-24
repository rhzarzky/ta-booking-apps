<template>
  <div class="p-4 sm:p-8 max-w-4xl mx-auto">
    <!-- Breadcrumb -->
    <div class="mb-6">
      <h1 class="text-2xl font-bold text-gray-800">Edit Profile</h1>
      <p class="text-sm text-gray-500 mt-1">
        <router-link to="/client/dashboard" class="hover:underline">Dashboard</router-link> /
        <router-link to="/client/profile" class="hover:underline">Profile</router-link> /
        <span class="text-indigo-600">Edit Profile</span>
      </p>
    </div>

    <!-- Form Container -->
    <div class="bg-white shadow-lg rounded-xl p-6 sm:p-10">
      <form @submit.prevent="handleSubmit" class="space-y-6">

        <!-- Image Upload -->
        <div class="flex flex-col sm:flex-row items-center gap-6">
          <div class="w-24 h-24 sm:w-28 sm:h-28 rounded-full overflow-hidden border shadow">
            <img
              :src="previewImage || auth.user?.image || defaultImage"
              alt="Profile"
              class="w-full h-full object-cover"
            />
          </div>
          <div class="flex-1">
            <label class="block text-sm font-medium text-gray-700 mb-1">Upload New Profile Image</label>
            <input
              type="file"
              accept="image/*"
              @change="onFileChange"
              class="block w-full text-sm text-gray-600 file:mr-4 file:py-1.5 file:px-4
                     file:rounded-md file:border-0 file:text-sm file:font-semibold
                     file:bg-blue-600 file:text-white hover:file:bg-blue-700"
            />
          </div>
        </div>

        <!-- Name -->
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Name</label>
          <input
            v-model="form.name"
            type="text"
            class="w-full px-4 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-400"
            required
          />
        </div>

        <!-- Email (readonly) -->
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Email</label>
          <input
            v-model="form.email"
            type="email"
            readonly
            class="w-full px-4 py-2 border bg-gray-100 text-gray-500 rounded-md"
          />
        </div>

        <!-- Action Buttons -->
        <div class="flex flex-col sm:flex-row justify-end gap-4 pt-4">
          <button
            type="button"
            @click="router.push('/client/profile')"
            class="w-full sm:w-auto px-6 py-2 rounded-md border border-gray-300 text-gray-700 hover:bg-gray-100 transition"
          >
            Cancel
          </button>
          <button
            type="submit"
            class="w-full sm:w-auto px-6 py-2 rounded-md bg-blue-600 text-white font-medium hover:bg-blue-700 transition"
          >
            Save Changes
          </button>
        </div>

      </form>
    </div>
  </div>
</template>

<script setup>
import { useRouter } from 'vue-router';
import { useAuthStore } from '@/stores/auth';
import { ref } from 'vue';
import defaultImage from '@/assets/images/foto.png';

const router = useRouter();
const auth = useAuthStore();

const form = ref({
  name: auth.user?.name || '',
  email: auth.user?.email || '',
  current_password: '',
  password: '',
  password_confirmation: '',
  image: null,
});

const previewImage = ref(null);

const onFileChange = (e) => {
  const file = e.target.files[0];
  form.value.image = file;
  if (file) {
    const reader = new FileReader();
    reader.onload = (e) => {
      previewImage.value = e.target.result;
    };
    reader.readAsDataURL(file);
  }
};

const handleSubmit = async () => {
  const formData = new FormData();
  formData.append('_method', 'PUT');
  formData.append('name', form.value.name);
  if (form.value.password) {
    formData.append('current_password', form.value.current_password);
    formData.append('password', form.value.password);
    formData.append('password_confirmation', form.value.password_confirmation);
  }
  if (form.value.image) {
    formData.append('image', form.value.image);
  }

  try {
    await auth.updateProfile(formData);
    alert('Profile updated successfully!');
    router.push('/client/profile');
  } catch (error) {
    console.error(error);
    alert('Failed to update profile.');
  }
};
</script>
