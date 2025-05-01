<script setup>
import { ref, onMounted } from 'vue';
import { useAuthStore } from '@/stores/auth';
import { useRouter } from 'vue-router';

const auth = useAuthStore();
const router = useRouter();

const name = ref('');
const email = ref('');
const image = ref(null);
const current_password = ref('');
const password = ref('');
const password_confirmation = ref('');

onMounted(() => {
  // Isi form dengan data user yang sudah login
  if (auth.user) {
    name.value = auth.user.name;
    email.value = auth.user.email;
  }
});

const submitForm = async () => {
  const formData = new FormData();
  formData.append('name', name.value);
  formData.append('email', email.value);

  if (image.value) {
    formData.append('image', image.value);
  }

  // Kirim password hanya jika ada perubahan
  if (current_password.value && password.value && password_confirmation.value) {
    formData.append('current_password', current_password.value);
    formData.append('password', password.value);
    formData.append('password_confirmation', password_confirmation.value);
  }

  try {
    const res = await auth.updateProfile(formData);
    console.log('Update success:', res);
    router.push('/client/profile');
  } catch (err) {
    console.error('Failed to update profile:', err);
  }
};
</script>

<template>
  <div class="p-8 max-w-xl mx-auto">
    <h1 class="text-2xl font-semibold mb-6">Edit Profile</h1>
    <form @submit.prevent="submitForm" class="space-y-4 bg-white p-6 rounded shadow">
      <div>
        <label class="block text-sm font-medium mb-1">Name</label>
        <input v-model="name" type="text" class="w-full border rounded px-3 py-2" required />
      </div>

      <div>
        <label class="block text-sm font-medium mb-1">Email</label>
        <input v-model="email" type="email" class="w-full border rounded px-3 py-2" required />
      </div>

      <div>
        <label class="block text-sm font-medium mb-1">Profile Image</label>
        <input type="file" @change="e => image.value = e.target.files[0]" class="w-full" />
      </div>

      <hr class="my-4" />

      <div>
        <label class="block text-sm font-medium mb-1">Current Password</label>
        <input v-model="current_password" type="password" class="w-full border rounded px-3 py-2" />
      </div>

      <div>
        <label class="block text-sm font-medium mb-1">New Password</label>
        <input v-model="password" type="password" class="w-full border rounded px-3 py-2" />
      </div>

      <div>
        <label class="block text-sm font-medium mb-1">Confirm New Password</label>
        <input v-model="password_confirmation" type="password" class="w-full border rounded px-3 py-2" />
      </div>

      <button type="submit" class="mt-4 px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700">
        Save Changes
      </button>
    </form>
  </div>
</template>
