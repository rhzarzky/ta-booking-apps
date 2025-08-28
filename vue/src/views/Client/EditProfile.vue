<script setup>
import { ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { useAuthStore } from '@/stores/auth';

const router = useRouter();
const auth = useAuthStore();

const form = ref({
  name: auth.user?.name || '',
  email: auth.user?.email || '',
  image: null,
});

const previewImage = ref(null);
const isLoading = ref(false);

// Avatar default jika user belum upload
const defaultAvatar = `https://ui-avatars.com/api/?name=${form.value.name || 'Pengguna'}&background=0D8ABC&color=fff`;

// Preview avatar dari user yang sudah login
onMounted(() => {
  if (auth.user?.avatar) {
    previewImage.value = auth.user.avatar;
  }
});

const onFileChange = (e) => {
  const file = e.target.files[0];
  if (file) {
    form.value.image = file;
    const reader = new FileReader();
    reader.onload = (event) => {
      previewImage.value = event.target.result;
    };
    reader.readAsDataURL(file);
  }
};

// Notifikasi
const notifications = ref([]);
let notificationId = 0;

const showNotification = (type, message) => {
  const id = notificationId++;
  notifications.value.push({ id, type, message });
  setTimeout(() => removeNotification(id), 3000);
};

const removeNotification = (id) => {
  notifications.value = notifications.value.filter((n) => n.id !== id);
};

// Submit form
const handleSubmit = async () => {
  isLoading.value = true;
  const formData = new FormData();
  formData.append('_method', 'PUT');
  formData.append('name', form.value.name);
  if (form.value.image) {
    formData.append('image', form.value.image);
  }

  try {
    await auth.updateProfile(formData);
    showNotification('success', 'Profile updated successfully!');
    if (auth.user) {
      auth.user.name = form.value.name;
      if (previewImage.value) {
        auth.user.avatar = previewImage.value;
      }
    }
    setTimeout(() => router.push('/client/profile'), 1000);
  } catch (error) {
    console.error(error);
    showNotification('error', 'Failed to update profile. Please try again.');
  } finally {
    isLoading.value = false;
  }
};

const handleBack = () => {
  window.history.back();
};
</script>

<style scoped>
.notification-fade-enter-active,
.notification-fade-leave-active {
  transition: all 0.5s ease;
}
.notification-fade-enter-from,
.notification-fade-leave-to {
  opacity: 0;
  transform: translateX(20px);
}
</style>

<template>
  <div class="relative max-w-4xl mx-auto p-6 bg-white rounded-lg shadow-xl mt-10">
    <!-- Tombol Icon Back -->
    <div class="flex items-center mb-4">
      <button
        @click="handleBack"
        class="flex items-center text-gray-600 hover:text-blue-600 font-medium"
      >
        <svg
          xmlns="http://www.w3.org/2000/svg"
          class="h-5 w-5 mr-2"
          fill="none"
          viewBox="0 0 24 24"
          stroke="currentColor"
        >
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
        </svg>
        Back
      </button>
    </div>

    <!-- Foto Profil -->
    <div class="flex items-center space-x-6 mb-8 border-b pb-6">
      <label for="profile-picture-input" class="cursor-pointer relative group">
        <img
          :src="previewImage || auth.user?.avatar || defaultAvatar"
          alt="Avatar Profil"
          class="w-28 h-28 rounded-full object-cover border-4 border-blue-500 shadow-lg transition-transform duration-300 group-hover:scale-105"
        />
        <div class="absolute inset-0 rounded-full bg-black bg-opacity-50 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity duration-300">
          <svg class="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.808-1.212A2 2 0 0110.618 3h2.764a2 2 0 011.664.89l.808 1.212a2 2 0 001.664.89H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z"></path>
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 13a3 3 0 11-6 0 3 3 0 016 0z"></path>
          </svg>
        </div>
        <input
          id="profile-picture-input"
          type="file"
          @change="onFileChange"
          class="hidden"
          accept="image/*"
        />
      </label>
      <p class="text-sm text-gray-500 mt-1">Click image to change profile picture</p>
    </div>

    <!-- Form Profil -->
    <h3 class="text-2xl font-semibold text-gray-800 mb-6">Personal Information</h3>
    <form @submit.prevent="handleSubmit" class="space-y-6">
      <div>
        <label for="name" class="block text-gray-700 text-sm font-semibold mb-2">Full Name</label>
        <input
          id="name"
          v-model="form.name"
          type="text"
          required
          class="w-full px-4 py-2 border border-gray-300 rounded-lg shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          placeholder="Masukkan nama lengkap Anda"
        />
      </div>

      <div>
        <label for="email" class="block text-gray-700 text-sm font-semibold mb-2">Email</label>
        <input
          id="email"
          v-model="form.email"
          type="email"
          readonly
          class="w-full px-4 py-2 border border-gray-300 rounded-lg bg-gray-100 text-gray-500 cursor-not-allowed"
        />
      </div>

      <div class="flex justify-end pt-4">
        <button
          type="submit"
          :disabled="isLoading"
          class="bg-blue-600 hover:bg-blue-700 text-white font-bold py-2 px-6 rounded-lg shadow-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-opacity-50"
        >
          <span v-if="!isLoading">Save</span>
          <span v-else>Saving...</span>
        </button>
      </div>
    </form>

    <!-- Notifikasi -->
    <div class="fixed top-4 right-4 space-y-2 z-50">
      <transition-group name="notification-fade">
        <div
          v-for="n in notifications"
          :key="n.id"
          :class="[
            'p-4 rounded-lg shadow-md flex items-center justify-between',
            n.type === 'success' ? 'bg-green-500 text-white' : 'bg-red-500 text-white'
          ]"
        >
          <span>{{ n.message }}</span>
          <button @click="removeNotification(n.id)" class="ml-4 text-white font-bold opacity-75 hover:opacity-100">
            <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>
      </transition-group>
    </div>
  </div>
</template>


