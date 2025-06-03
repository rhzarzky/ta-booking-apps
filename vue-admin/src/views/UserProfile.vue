<script setup>
import DefaultLayout from "@/layout/DefaultLayout.vue";

import { useAuthStore } from "@/stores/auth";
import { useRouter } from 'vue-router';

import { ref, onMounted } from "vue";

const authStore = useAuthStore();
const loading = ref(true);
const router = useRouter();

const getUserProfile = async () => {
  try {
    await authStore.handleUserProfile();
  } catch (error) {
    console.error("Failed to fetch user profile:", error);
  } finally {
    loading.value = false; 
  }
};

onMounted(() => {
  getUserProfile();
});

const goToEditProfile = () => {
  router.push({ name: 'Edit Profile' }); 
};
</script>

<template>
  <DefaultLayout class="bg-whiteBgPrimary-100">
    <div class="bg-white flex flex-col gap-10 py-6 md:py-14 rounded-2xl">
      <div class="flex flex-col gap-6 p-5 rounded-xl border border-wildsand-300 mx-6 md:mx-14">
        <div class="flex md:flex-row flex-col justify-between md:items-center gap-4 md:gap-0">
          <p class="text-base md:text-xl text-codgray-900 font-semibold">Personal Info</p>
          <button
            @click="goToEditProfile"
            class="flex gap-1 md:gap-2 md:px-6 md:py-3 px-2 py-2 max-w-fit rounded-xl border-2 text-cobalt-600 border-cobalt-600"
          >
            Edit Info
          </button>
        </div>
        <div class="flex flex-col gap-6 justify-between items-start">
          <div class="flex flex-col gap-1">
            <h4 class="text-codgray-600 text-base">Name</h4>
            <p class="text-codgray-900 text-base font-semibold">
              {{ authStore.user?.name || "Loading..." }}
            </p>
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