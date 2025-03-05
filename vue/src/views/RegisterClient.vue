<template>
  <div class="flex h-screen bg-gray-100">
    <!-- Form Register -->
    <div class="w-1/2 flex items-center justify-center p-8">
      <div class="w-full max-w-lg"> <!-- Memperlebar form dengan max-w-lg -->
        <!-- Logo -->
        <img src="@/assets/images/Appointly.png" alt="Logo Appointly" class="h-10 mb-6">
        
        <h2 class="text-3xl font-bold text-gray-800">Unlock Your Experience!</h2>
        <p class="text-gray-500 mb-6">Create an account and unlock your next great scheduling.</p>

        <!-- Form -->
        <form @submit.prevent="handleRegister" class="space-y-4">
          <div>
            <label class="block text-gray-700 font-medium">Full Name</label>
            <input type="text" v-model="name" placeholder="John Doe" class="w-full px-4 py-3 border rounded-lg focus:ring-2 focus:ring-indigo-400" required />
          </div>
          <div>
            <label class="block text-gray-700 font-medium">Email</label>
            <input type="email" v-model="email" placeholder="Jhondoe@gmail.com" class="w-full px-4 py-3 border rounded-lg focus:ring-2 focus:ring-indigo-400" required />
          </div>
          <div>
            <label class="block text-gray-700 font-medium">Password</label>
            <input type="password" v-model="password" placeholder="Max. 8 Characters" class="w-full px-4 py-3 border rounded-lg focus:ring-2 focus:ring-indigo-400" required />
          </div>
          <div>
            <label class="block text-gray-700 font-medium">Confirm Password</label>
            <input type="password" v-model="confirmPassword" placeholder="Confirm your password" class="w-full px-4 py-3 border rounded-lg focus:ring-2 focus:ring-indigo-400" required />
          </div>
          <button type="submit" class="w-full bg-indigo-600 text-white py-3 rounded-lg font-semibold hover:bg-indigo-700">
            Get Started
          </button>
        </form>

        <!-- OR -->
        <div class="flex items-center my-6">
          <hr class="flex-grow border-gray-300">
          <span class="px-4 text-gray-400">Or</span>
          <hr class="flex-grow border-gray-300">
        </div>

        <!-- Google Login -->
        <button class="w-full flex items-center justify-center border py-3 rounded-lg font-semibold text-gray-700 hover:bg-gray-100">
          <img src="@/assets/images/google.png" class="h-5 w-5 mr-2" />
          Continue with Google
        </button>

        <!-- Login Link -->
        <p class="text-center text-gray-600 mt-6">
          Already have an account?
          <router-link to="/login" class="text-indigo-600 font-semibold">Sign in</router-link>
        </p>
      </div>
    </div>

    <!-- Image Section -->
    <div class="w-1/2 flex items-center justify-center bg-gray-100 p-8 relative rounded-l-lg">
      <img src="@/assets/images/gambar1.jpeg" class="w-full h-full object-cover object-center rounded-lg shadow-lg" style="max-width: 100%; max-height: 100vh;" />
      <div class="absolute inset-0 flex flex-col justify-end text-white p-8 rounded-lg">
        <h3 class="text-3xl font-bold">Say goodbye to manual scheduling hassles</h3>
        <p class="mt-2 text-lg">Our smart appointment booking system allows you to manage your schedule effortlessly.</p>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'RegisterClient',
  data() {
    return {
      name: '',
      email: '',
      password: '',
      confirmPassword: '',
    };
  },
  methods: {
    handleRegister() {
      if (this.password !== this.confirmPassword) {
        alert('Passwords do not match');
        return;
      }
      console.log('Registering with:', this.name, this.email, this.password);
      this.$router.push('/client/dashboard');
    },
  },
};
</script>
