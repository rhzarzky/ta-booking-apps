<script setup>
import { useAuthStore } from "@/stores/auth";
import { useRouter } from "vue-router";
import { reactive, watch, ref } from "vue";
import { storeToRefs } from "pinia";

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

const handleSubmit = async () => {
  isSubmitted.value = true;

  try {
    await store.handleLogin(form);
    router.push({ name: "Service" });
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
                  class="mt-1 block w-full px-4 py-3 border-2 border-wildsand-200 rounded-lg text-codgray-900 cursor-pointer focus:outline-none focus:ring-2 focus:ring-offset-2 focus:text-cobalt-700 focus:ring-cobalt-600 hover:border-cobalt-500 transition-colors duration-200 text-sm"
                  placeholder="abcd@gmail.com" :class="{ 'border-red-500': isSubmitted && errors.email }"
                  v-model="form.email" />
                <div v-if="isSubmitted && errors.email" class="text-red-500 text-sm mt-1">
                  {{ Array.isArray(errors.email) ? errors.email[0] : errors.email }}
                </div>
              </div>

              <div>
                <label for="password" class="block text-sm text-codgray-700 font-medium">Password</label>
                <input id="password" name="password" type="password" required autocomplete="current-password"
                  class="mt-1 block w-full px-4 py-3 border-2 border-wildsand-200 rounded-lg text-codgray-900 cursor-pointer focus:outline-none focus:ring-2 focus:ring-offset-2 focus:text-cobalt-700 focus:ring-cobalt-600 hover:border-cobalt-500 transition-colors duration-200 text-sm"
                  placeholder="Enter your password" :class="{ 'border-red-500': isSubmitted && errors.password }"
                  v-model="form.password" />
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