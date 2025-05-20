<script setup>
import DefaultLayout from "@/layout/DefaultLayout.vue";
import { ref, onMounted, reactive } from "vue";
import { useRouter, useRoute } from "vue-router";
import { useAuthStore } from "@/stores/auth";
import showIcon from "@/assets/image/showps.png";
import hideIcon from "@/assets/image/hideps.png";
import AlertStatus from "@/components/alert/AlertStatus.vue";

const authStore = useAuthStore();
const router = useRouter();
const route = useRoute();

const loading = ref(true);
const isEditing = ref(false);

// Password form data
const post = ref({
  password: "",
  confirmPassword: "",
});

// Password visibility state
const isPasswordVisible = reactive({
  password: false,
  confirmPassword: false,
});

const togglePasswordVisibility = (field) => {
  isPasswordVisible[field] = !isPasswordVisible[field];
};

// Generate a random secure password
const generatePassword = () => {
  const length = 12;
  const charset =
    "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_+[]{}|;:,.<>?";
  let result = "";
  for (let i = 0; i < length; i++) {
    result += charset.charAt(Math.floor(Math.random() * charset.length));
  }
  post.value.password = result;
  post.value.confirmPassword = result;
};

// The user ID to edit
const userIdToEdit = ref(route.params.id);

// Fetch user data by ID
const getUser = async (userId) => {
  try {
    loading.value = true;
    await authStore.handleGetUserById(userId);
  } catch (error) {
    console.error("Failed to fetch user data", error);
    authStore.notification.message = "Failed to load user data.";
    authStore.notification.type = "error";
    authStore.notification.show = true;
  } finally {
    loading.value = false;
  }
};

// Save updated password
const saveUserUpdates = async () => {
  if (post.value.password !== post.value.confirmPassword) {
    authStore.showNotification("Passwords do not match.", "error");
    return;
  }

  if (!userIdToEdit.value) {
    authStore.showNotification("User ID is not provided.", "error");
    return;
  }

  try {
    const userData = {
      password: post.value.password,
      password_confirmation: post.value.confirmPassword,
    };

    await authStore.handleUpdateUser(userIdToEdit.value, userData);
    isEditing.value = false;
    authStore.showNotification("Password updated successfully.", "success");
  } catch (error) {
    console.error("FULL ERROR OBJECT:", error);

    let errorMessage = "An unexpected error occurred.";

    if (error.response && error.response.data) {
      const responseErrors = error.response.data.errors;
      if (responseErrors) {
        errorMessage = Object.values(responseErrors).flat().join(", ");
      } else if (error.response.data.message) {
        errorMessage = error.response.data.message;
      } else {
        errorMessage = JSON.stringify(error.response.data);
      }
    } else if (error.message) {
      errorMessage = error.message;
    }

    authStore.showNotification("Failed to update password: ", "error:" + errorMessage);
  }
};

onMounted(() => {
  if (userIdToEdit.value) {
    getUser(userIdToEdit.value);
  } else {
    authStore.showNotification("User ID is not provided.", "error");
  }
});

// Cancel button
const cancel = () => {
  router.push({ path: "/user-list" });
};
</script>

<template>
  <DefaultLayout class="bg-whiteBgPrimary-100">
    <div class="max-h-fit md:p-9 p-4 flex flex-col gap-6 bg-white rounded-2xl">
      <div class="flex flex-col gap-1">
        <!-- Notification -->
        <AlertStatus :message="authStore.notification.message" :type="authStore.notification.type"
          :is-visible="authStore.notification.show" @close="authStore.notification.show = false" />
        <h2 class="text-codgray-900 md:text-2xl text-base font-semibold">
          Change Password Account
        </h2>
        <p class="md:text-base text-sm text-wildsand-400">
          Please fill in this field to proceed with updating the user.
        </p>
      </div>

      <form @submit.prevent="saveUserUpdates" class="flex flex-col gap-6">
        <!-- New Password -->
        <div class="flex flex-col gap-2">
          <label class="text-sm md:text-base text-wildsand-600" for="password">
            New Password
          </label>
          <div class="flex items-center gap-2">
            <div class="relative w-full">
              <input
                class="w-full hover:border-cobalt-700 h-12 border border-wildsand-300 hover:bg-cobalt-50 focus:outline-none focus:ring-1 focus:ring-cobalt-700 text-codgray-900 rounded-md shadow-sm p-2 text-base placeholder-small"
                id="password" :type="isPasswordVisible.password ? 'text' : 'password'" v-model="post.password"
                placeholder="Enter new password" />
              <img :src="isPasswordVisible.password ? showIcon : hideIcon" @click="togglePasswordVisibility('password')"
                class="absolute top-1/2 right-3 transform -translate-y-1/2 cursor-pointer w-5 h-5"
                alt="Toggle password visibility" />
            </div>
            <button type="button" class="bg-cobalt-700 text-white rounded px-4 py-2 flex-shrink-0"
              @click="generatePassword">
              Generate Password
            </button>
          </div>
        </div>

        <!-- Confirm Password -->
        <div class="flex flex-col gap-2">
          <label class="text-sm md:text-base text-wildsand-600 flex gap-1" for="confirm-password">
            Confirm Password
          </label>
          <div class="relative">
            <input
              class="w-full hover:border-cobalt-700 h-12 border border-wildsand-300 hover:bg-cobalt-50 focus:outline-none focus:ring-1 focus:ring-cobalt-700 text-codgray-900 rounded-md shadow-sm p-2 text-base placeholder-small"
              id="confirm-password" :type="isPasswordVisible.confirmPassword ? 'text' : 'password'"
              v-model="post.confirmPassword" placeholder="Confirm new password" />
            <img :src="isPasswordVisible.confirmPassword ? showIcon : hideIcon"
              @click="togglePasswordVisibility('confirmPassword')"
              class="absolute top-1/2 right-3 transform -translate-y-1/2 cursor-pointer w-5 h-5"
              alt="Toggle password visibility" />
          </div>
        </div>

        <div class="flex gap-4 justify-end w-full">
          <button type="button"
            class="md:px-6 md:py-3 px-4 max-w-fit font-semibold py-2 bg-transparent text-cobalt-700 border-2 border-cobalt-700 rounded-xl w-36 hover:bg-gray-300"
            @click="cancel">
            Cancel
          </button>
          <button type="submit"
            class="md:px-6 md:py-3 px-4 max-w-fit font-semibold py-2 bg-gradient-to-b from-cobalt-700 to-cobalt-900 text-white rounded-xl w-36">
            Save
          </button>
        </div>
      </form>
    </div>
  </DefaultLayout>
</template>
