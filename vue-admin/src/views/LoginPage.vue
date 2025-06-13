<script setup>
import { useAuthStore } from "@/stores/auth";
import { useRouter } from "vue-router";
import { reactive, watch, ref } from "vue";
import { storeToRefs } from "pinia";
import showIcon from "@/assets/image/showps.png";
import hideIcon from "@/assets/image/hideps.png";

const router = useRouter();
const store = useAuthStore();
const { isLoggedIn, errors, loading } = storeToRefs(store);

// Add refs to track if form has been submitted
const isSubmitted = ref(false);

const form = reactive({
  email: "",
  password: "",
});

watch(isLoggedIn, (newValue) => {
  if (newValue) {
    router.push({ name: "Service" });
  }
});

// Variabel untuk visibilitas password
const isPasswordVisible = ref({
  password: false,
  confirmPassword: false,
});

// Fungsi toggle visibilitas password
const togglePasswordVisibility = (field) => {
  isPasswordVisible.value[field] = !isPasswordVisible.value[field];
};

const handleSubmit = async () => {
  isSubmitted.value = true;

  try {
    await store.handleLogin(form);
    router.push({ name: "Admin Dashboard" });
  } catch (error) {
    console.error("Login failed:", error);
  }
};
</script>

<template>
  <main class="min-h-screen flex items-center justify-center">
    <div class="relative flex w-full items-center justify-center">
      <div class="w-full bg-white shadow-lg rounded-lg">
        <div class="min-h-[100dvh] p-6 md:p-8 lg:p-12 flex items-center justify-center">
          <div class="max-w-md w-full md:mt-12 mx-auto">
            <div class="flex flex-col gap-1 mb-6">
              <h2 class="text-2xl font-semibold text-codgray-900">
                Admin Dashboard
              </h2>
              <p class="text-sm text-wildsand-300">
                Complete the form to access your account
              </p>
            </div>
            <form method="POST" class="space-y-6" @submit.prevent="handleSubmit">
              <div>
                <label for="email" class="block text-sm text-codgray-700 font-medium">Email address</label>
                <input id="email" name="email" type="email" required autofocus
                  class="w-full hover:border-cobalt-700 h-12 border border-wildsand-300 hover:bg-cobalt-50 focus:outline-none focus:ring-1 focus:ring-cobalt-700 text-codgray-900 rounded-md shadow-sm p-2 text-base placeholder-small"
                  placeholder="abcd@gmail.com" :class="{ 'border-red-500': isSubmitted && errors.email }"
                  v-model="form.email" />
                <div v-if="isSubmitted && errors.email" class="text-red-500 text-sm mt-1">
                  {{ Array.isArray(errors.email) ? errors.email[0] : errors.email }}
                </div>
              </div>

              <div class="relative">
                <label for="password" class="block text-sm text-codgray-700 font-medium">Password</label>
                <input id="password" name="password" :type="isPasswordVisible.password ? 'text' : 'password'" required
                  autocomplete="current-password"
                  class="w-full hover:border-cobalt-700 h-12 border border-wildsand-300 hover:bg-cobalt-50 focus:outline-none focus:ring-1 focus:ring-cobalt-700 text-codgray-900 rounded-md shadow-sm p-2 text-base placeholder-small"
                  placeholder="Enter your password" :class="{ 'border-red-500': isSubmitted && errors.password }"
                  v-model="form.password" />
                <img :src="isPasswordVisible.password ? showIcon : hideIcon"
                  @click="togglePasswordVisibility('password')"
                  class="absolute top-[65%] right-3 -translate-y-1/2 cursor-pointer w-5 h-5"
                  alt="Toggle password visibility" />
                <div v-if="isSubmitted && errors.password" class="text-red-500 text-sm mt-1">
                  {{ Array.isArray(errors.password) ? errors.password[0] : errors.password }}
                </div>
              </div>

              <!-- Only show general errors if they exist and the form has been submitted -->
              <div v-if="isSubmitted && errors.general" class="text-red-500 text-sm mt-2">
                {{ Array.isArray(errors.general) ? errors.general[0] : errors.general }}
              </div>

              <div class="flex items-center justify-between">
                <button type="submit"
                  class="w-full font-medium bg-gradient-to-b from-cobalt-700 to-cobalt-900 text-white py-3 px-6 rounded-xl hover:bg-cobalt-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-cobalt-800"
                  :disabled="loading">
                  <span v-if="loading">Loading...</span>
                  <span v-else>Log in</span>
                </button>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>
  </main>
</template>