<script setup>
import DefaultLayout from "@/layout/DefaultLayout.vue";

import { ref, onMounted, watch } from "vue";
import { useAuthStore } from "@/stores/auth";
import { useRouter } from 'vue-router';
import AlertStatus from "@/components/alert/AlertStatus.vue";

const authStore = useAuthStore();
const loading = ref(true);
const name = ref('');
const router = useRouter();
const showNotification = ref(false);

const getUserProfile = async () => {
  try {
    await authStore.handleUserProfile();
    name.value = authStore.user?.name || '';
  } catch (error) {
    console.error("Failed to fetch user profile:", error);
  } finally {
    loading.value = false;
  }
};

const saveProfileUpdates = async () => {
  try {
    const userData = {
      name: name.value,
    };
    await authStore.handleUpdateProfile(userData);
    authStore.showNotification("Profile updated successfully.", "success");
    showNotification.value = true;
    router.push({ name: 'User Profile' });
  } catch (error) {
    authStore.showNotification("Failed to update profile.", "error");
    showNotification.value = true;
    console.error("Error updating profile:", error);
  }
};

// Watch notification state from store and update local showNotification
watch(
  () => authStore.notification.show,
  (val) => {
    showNotification.value = val;
  }
);

onMounted(() => {
  getUserProfile();
});
</script>

<template>
  <DefaultLayout class="bg-whiteBgPrimary-100">
    <div class="bg-white flex flex-col gap-10 py-6 md:py-14 rounded-2xl">
      <!-- Notification -->
      <AlertStatus :message="authStore.notification.message" :type="authStore.notification.type"
        :is-visible="showNotification" @close="showNotification = false; authStore.notification.show = false" />
      <div class="flex flex-col gap-6 p-5 rounded-xl border border-wildsand-300 mx-6 md:mx-14">
        <div class="flex md:flex-row flex-col justify-between md:items-center gap-4 md:gap-0">
          <p class="text-base md:text-xl text-codgray-900 font-semibold">Edit Personal Info</p>
          <button @click="saveProfileUpdates"
            class="flex gap-1 md:gap-2 md:px-6 md:py-3 px-2 py-2 max-w-fit rounded-xl border-2 bg-cobalt-600 text-white border-cobalt-600">
            Save Info
          </button>
        </div>
        <div class="flex flex-col gap-6 justify-between items-stretch">
          <div class="flex flex-col gap-1">
            <h4 class="text-codgray-600 text-base">Name</h4>
            <input
              class="w-full hover:border-cobalt-700 h-12 border border-wildsand-300 hover:bg-cobalt-50 focus:outline-none focus:ring-1 focus:ring-cobalt-700 text-codgray-900 rounded-md shadow-sm p-2 text-base placeholder-small"
              id="name" type="text" v-model="name" placeholder="Enter user name" />
          </div>
          <div class="flex flex-col gap-1">
            <h4 class="text-codgray-600 text-base">Email Address</h4>
            <p class="text-codgray-900 text-base font-semibold">
              {{ authStore.user?.email || "Loading..." }}
            </p>
          </div>
          <div class="flex flex-col gap-1">
            <h4 class="text-codgray-600 text-base">Role</h4>
            <p class="text-codgray-900 text-base font-semibold">
              {{ authStore.user?.role?.join(', ') || "Loading..." }}
            </p>
          </div>
        </div>
      </div>
    </div>
  </DefaultLayout>
</template>