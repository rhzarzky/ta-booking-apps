<template>
  <div class="p-8 bg-gray-100 min-h-screen">
    <div class="max-w-xl mx-auto bg-white p-6 rounded-lg shadow-md">
      <h2 class="text-2xl font-bold text-gray-800 mb-6">Edit Profile</h2>

      <form @submit.prevent="saveProfile" class="space-y-6">
        <!-- Full Name -->
        <div>
          <label for="fullName" class="block text-sm font-medium text-gray-700 mb-1">Full Name</label>
          <input
            type="text"
            id="fullName"
            v-model="form.fullName"
            class="w-full border border-gray-300 rounded-md px-4 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500"
            required
          />
        </div>

        <!-- Email -->
        <div>
          <label for="email" class="block text-sm font-medium text-gray-700 mb-1">Email</label>
          <input
            type="email"
            id="email"
            v-model="form.email"
            class="w-full border border-gray-300 rounded-md px-4 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500"
            required
          />
        </div>

        <!-- Password -->
        <div>
          <label for="password" class="block text-sm font-medium text-gray-700 mb-1">Password</label>
          <input
            type="password"
            id="password"
            v-model="form.password"
            class="w-full border border-gray-300 rounded-md px-4 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500"
            placeholder="Enter new password"
          />
        </div>

        <!-- Buttons -->
        <div class="flex justify-end space-x-4">
          <router-link
            to="/profile"
            class="px-4 py-2 border rounded-md text-gray-600 hover:bg-gray-100"
          >
            Cancel
          </router-link>
          <button
            type="submit"
            class="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700"
          >
            Save Changes
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script>
export default {
  name: 'EditProfile',
  data() {
    return {
      form: {
        fullName: 'Alexandri Jeen',
        email: 'AlexandriJeen@mail.com',
        password: '',
      },
    };
  },
  methods: {
    saveProfile() {
      // Simulasikan proses penyimpanan data
      console.log('Saved profile data:', this.form);

      // Redirect ke halaman profile (jika pakai vue-router)
      this.$router.push('/client/profile');
    },
  },
};
</script>
