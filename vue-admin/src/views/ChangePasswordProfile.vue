<script setup>
import DefaultLayout from "@/layout/DefaultLayout.vue";
import { ref, reactive } from "vue";
import { useRouter } from "vue-router";
import { useAuthStore } from "@/stores/auth";
import showIcon from "@/assets/image/showps.png";
import hideIcon from "@/assets/image/hideps.png";
import AlertStatus from "@/components/alert/AlertStatus.vue";

const authStore = useAuthStore();
const router = useRouter();

// Password form data
const post = ref({
  currentPassword: "",
  password: "",
  confirmPassword: "",
});

// Password visibility state
const isPasswordVisible = reactive({
  currentPassword: false,
  password: false,
  confirmPassword: false,
});

const togglePasswordVisibility = (field) => {
  isPasswordVisible[field] = !isPasswordVisible[field];
};

// Save updated password
const saveUserUpdates = async () => {
  if (!post.value.currentPassword) {
    authStore.showNotification("Current password is required.", "error");
    return;
  }
  if (post.value.password !== post.value.confirmPassword) {
    authStore.showNotification("Passwords do not match.", "error");
    return;
  }

  try {
    const userData = {
      current_password: post.value.currentPassword,
      password: post.value.password,
      password_confirmation: post.value.confirmPassword,
    };

    await authStore.handleUpdateProfile(userData);
    authStore.showNotification("Password updated successfully.", "success");
    router.push({ path: "/user-list" });
  } catch (error) {
    const errors = error.response?.data?.errors || {};
    const message =
      Array.isArray(errors.password) ? errors.password[0] :
        Array.isArray(errors.current_password) ? errors.current_password[0] :
          error.response?.data?.message ||
          "Failed to update password.";

    authStore.showNotification(message, "error");
  }
};

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
        <!-- Current Password -->
        <div class="flex flex-col gap-2">
          <label class="text-sm md:text-base text-wildsand-600" for="current-password">
            Current Password
          </label>
          <div class="flex items-center gap-2">
            <div class="relative w-full">
              <input
          class="w-full hover:border-cobalt-700 h-12 border border-wildsand-300 hover:bg-cobalt-50 focus:outline-none focus:ring-1 focus:ring-cobalt-700 text-codgray-900 rounded-md shadow-sm p-2 text-base placeholder-small"
          id="current-password" :type="isPasswordVisible.currentPassword ? 'text' : 'password'" v-model="post.currentPassword"
          placeholder="Enter current password" />
              <img :src="isPasswordVisible.currentPassword ? showIcon : hideIcon" @click="togglePasswordVisibility('currentPassword')"
          class="absolute top-1/2 right-3 transform -translate-y-1/2 cursor-pointer w-5 h-5"
          alt="Toggle password visibility" />
            </div>
          </div>
        </div>
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
