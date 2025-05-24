<script setup>
import { ref, computed, onMounted } from "vue";
import { useAuthStore } from "@/stores/auth";
import { storeToRefs } from "pinia";
import { useRouter } from "vue-router";

const router = useRouter();
const dropdownOpen = ref(false);
const isLoggingOut = ref(false);

const authStore = useAuthStore();
const { user } = storeToRefs(authStore);

// Ambil data user saat komponen dimuat
onMounted(async () => {
  if (!user.value) {
    try {
      await authStore.getCurrentUser();
    } catch (error) {
      console.error("Gagal mengambil user:", error);
    }
  }
});

const toggleDropdown = () => {
  dropdownOpen.value = !dropdownOpen.value;
};

const logout = async () => {
  isLoggingOut.value = true;
  authStore.handleLogout();
  router.push("/login");
};

const userInfo = computed(() => ({
  name: user.value?.name || "-",
  role: Array.isArray(user.value?.role) ? user.value.role[0] : "-",
  image: user.value?.image || null,
}));
</script>

<template>
  <div class="relative">
    <button
      @click.prevent="toggleDropdown"
      class="flex items-center gap-3 w-full p-2 hover:bg-gray-100 rounded-lg transition-colors"
    >
      <div class="flex-shrink-0">
        <img
          v-if="userInfo.image"
          :src="userInfo.image"
          alt="Avatar"
          class="w-8 h-8 rounded-full object-cover"
        />
        <div
          v-else
          class="w-8 h-8 rounded-full bg-gray-300 flex items-center justify-center text-sm font-semibold text-white"
        >
          {{ userInfo.name.charAt(0).toUpperCase() }}
        </div>
      </div>

      <div class="hidden md:block text-left">
        <h5 class="text-sm font-medium text-codgray-950 truncate max-w-[150px]">
          {{ userInfo.name }}
        </h5>
        <p class="text-xs text-codgray-600 truncate max-w-[150px]">
          {{ userInfo.role }}
        </p>
      </div>

      <svg
        :class="{ 'rotate-180': dropdownOpen }"
        class="size-3 text-codgray-600 transition-transform ml-auto"
        viewBox="0 0 12 8"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
      >
        <path
          fill-rule="evenodd"
          clip-rule="evenodd"
          d="M0.410765 0.910734C0.736202 0.585297 1.26384 0.585297 1.58928 0.910734L6.00002 5.32148L10.4108 0.910734C10.7362 0.585297 11.2638 0.585297 11.5893 0.910734C11.9147 1.23617 11.9147 1.76381 11.5893 2.08924L6.58928 7.08924C6.26384 7.41468 5.7362 7.41468 5.41077 7.08924L0.410765 2.08924C0.0853277 1.76381 0.0853277 1.23617 0.410765 0.910734Z"
          fill="currentColor"
        />
      </svg>
    </button>

    <transition
      enter-active-class="transition duration-200 ease-out"
      enter-from-class="scale-95 opacity-0"
      enter-to-class="scale-100 opacity-100"
      leave-active-class="transition duration-100 ease-in"
      leave-from-class="scale-100 opacity-100"
      leave-to-class="scale-95 opacity-0"
    >
      <div
        v-show="dropdownOpen"
        class="absolute right-0 mt-2 w-56 origin-top-right rounded-xl bg-white shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none z-50"
      >
        <div class="py-1">
          <router-link
            to="/client/change-password"
            class="block w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 transition-colors"
          >
            Change Password
          </router-link>
          <button
            @click="logout"
            :disabled="isLoggingOut"
            class="block w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {{ isLoggingOut ? "Logging out..." : "Logout" }}
          </button>
        </div>
      </div>
    </transition>
  </div>
</template>
