<script setup>
import { reactive, ref, onMounted } from "vue";
import { useRouter } from "vue-router";
import DefaultLayout from "@/layout/DefaultLayout.vue";
import { useAuthStore } from "@/stores/auth";
import showIcon from "@/assets/image/showps.png";
import hideIcon from "@/assets/image/hideps.png";
import AlertStatus from "@/components/alert/AlertStatus.vue";
import { useRoleStore } from "@/stores/role";

const authStore = useAuthStore();
const roleStore = useRoleStore();
const router = useRouter();
const userRoles = ref([]);

const post = reactive({
  name: "",
  email: "",
  password: "",
  confirmPassword: "",
  role: "",
  status: "",
});

const validation = ref([]);
const notification = ref("");

// Function to fetch roles from API
onMounted(async () => {
  userRoles.value = await roleStore.fetchRoleApi();
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

// Fungsi untuk generate password
const generatePassword = () => {
  const length = 12; // Panjang password
  const charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_+[]{}|;:,.<>?"; // Karakter yang digunakan untuk password
  let result = "";
  for (let i = 0; i < length; i++) {
    result += charset.charAt(Math.floor(Math.random() * charset.length));
  }
  post.password = result;
  post.confirmPassword = result; // Auto-fill confirm password dengan password yang dihasilkan
};

const store = async () => {
  if (post.password !== post.confirmPassword) {
    validation.value = { confirmPassword: ["Password do not match"] };
    return;
  }

  const userData = {
    name: post.name,
    email: post.email,
    password: post.password,
    password_confirmation: post.confirmPassword,
    role: post.role,
  };
  try {
    await authStore.handleCreateUser(userData);
    authStore.showNotification("User created successfully.", "success");
    router.push("/user-list");
  } catch (error) {
    console.error("Error creating user:", error);
    authStore.showNotification(error.response.data.responseMessage, "error");
    if (error.response) {
      console.error("Response data:", error.response.data);
      authStore.showNotification("Error creating user", "error");
      validation.value = error.response.data.errors || {};
    }
  }
};

// Fungsi untuk tombol Cancel
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
          Create your account
        </h2>
        <p class="md:text-base text-sm text-wildsand-400">
          Start here! Complete this field to move forward
        </p>
      </div>
      <form @submit.prevent="store" class="flex flex-col gap-6">
        <div class="flex flex-col gap-2">
          <label class="text-sm md:text-base text-wildsand-600 flex gap-1" for="name">Name
            <span class="text-red-600">*</span>
          </label>
          <input
            class="w-full hover:border-cobalt-700 h-12 border border-wildsand-300 hover:bg-cobalt-50 focus:outline-none focus:ring-1 focus:ring-cobalt-700 text-codgray-900 rounded-md shadow-sm p-2 text-base placeholder-small"
            id="name" placeholder="Enter user name" type="text" v-model="post.name" />
          <!-- validation -->
          <div class="mt-2 text-red-600" v-if="validation.name">
            {{ validation.name[0] }}
          </div>
        </div>
        <div class="flex flex-col gap-2">
          <label class="text-sm md:text-base text-wildsand-600 flex gap-1" for="email">Email
            <span class="text-red-600">*</span>
          </label>
          <input
            class="w-full hover:border-cobalt-700 h-12 border border-wildsand-300 hover:bg-cobalt-50 focus:outline-none focus:ring-1 focus:ring-cobalt-700 text-codgray-900 rounded-md shadow-sm p-2 text-base placeholder-small"
            id="email" placeholder="Enter user email" type="email" v-model="post.email" />
          <!-- validation -->
          <div class="mt-2 text-red-600" v-if="validation.email">
            {{ validation.email[0] }}
          </div>
        </div>
        <div class="flex flex-col gap-2">
          <label class="text-base text-wildsand-600 flex gap-1" for="password">
            Password <span class="text-red-600">*</span>
          </label>
          <div class="flex items-center gap-2">
            <div class="relative w-full">
              <input
                class="w-full hover:border-cobalt-700 h-12 border border-wildsand-300 hover:bg-cobalt-50 focus:outline-none focus:ring-1 focus:ring-cobalt-700 text-codgray-900 rounded-md shadow-sm p-2 text-base placeholder-small"
                :type="isPasswordVisible.password ? 'text' : 'password'" id="password" placeholder="Enter user password"
                v-model="post.password" />
              <img :src="isPasswordVisible.password ? showIcon : hideIcon" @click="togglePasswordVisibility('password')"
                class="absolute top-1/2 right-3 transform -translate-y-1/2 cursor-pointer w-5 h-5"
                alt="Toggle password visibility" />
            </div>
            <button type="button" class="bg-cobalt-700 text-white rounded px-4 py-2 flex-shrink-0"
              @click="generatePassword">
              Generate Password
            </button>
          </div>
          <!-- validation -->
          <div class="mt-2 text-red-600" v-if="validation.password">
            {{ validation.password[0] }}
          </div>
        </div>

        <div class="flex flex-col gap-2">
          <label class="text-base text-wildsand-600 flex gap-1" for="confirm-password">Confirm Password <span
              class="text-red-600">*</span></label>
          <div class="relative">
            <input
              class="w-full hover:border-cobalt-700 h-12 border border-wildsand-300 hover:bg-cobalt-50 focus:outline-none focus:ring-1 focus:ring-cobalt-700 text-codgray-900 rounded-md shadow-sm p-2 text-base placeholder-small"
              :type="isPasswordVisible.confirmPassword ? 'text' : 'password'" id="confirm-password"
              placeholder="Confirm user password" v-model="post.confirmPassword" />
            <img :src="isPasswordVisible.confirmPassword ? showIcon : hideIcon"
              @click="togglePasswordVisibility('confirmPassword')"
              class="absolute top-1/2 right-3 transform -translate-y-1/2 cursor-pointer w-5 h-5"
              alt="Toggle password visibility" />
          </div>
          <!-- validation -->
          <div class="mt-2 text-red-600" v-if="validation.confirmPassword">
            {{ validation.confirmPassword[0] }}
          </div>
        </div>

        <div class="flex flex-col gap-2">
          <label class="text-sm md:text-base text-wildsand-600 flex gap-1" for="role">Role <span
              class="text-red-600">*</span></label>
          <select id="role"
            class="w-full h-12 border border-wildsand-300 hover:bg-cobalt-50 focus:outline-none focus:ring-1 focus:ring-cobalt-700 text-codgray-900 rounded-md shadow-sm p-2 text-base"
            v-model="post.role">
            <option value="" disabled>Select a role</option>
            <option v-for="role in userRoles" :key="role.id" :value="role.name">
              {{ role.name }}
            </option>
          </select>
          <!-- validation -->
          <div class="mt-2 text-red-600" v-if="validation.role">
            {{ validation.role[0] }}
          </div>
        </div>

        <div class="justify-end flex w-full gap-4">
          <!-- Tombol Cancel -->
          <button type="button"
            class="md:px-6 md:py-3 px-4 max-w-fit font-semibold py-2 bg-gray-200 text-gray-700 rounded-xl w-36 hover:bg-gray-300"
            @click="cancel">
            Cancel
          </button>
          <!-- Tombol Add User -->
          <button type="submit"
            class="md:px-6 md:py-3 px-4 max-w-fit font-semibold py-2 bg-gradient-to-b from-cobalt-700 to-cobalt-900 text-white rounded-xl w-36">
            Add User
          </button>
        </div>

        <!-- Notifikasi -->
        <div v-if="notification" class="mt-4 p-4 bg-green-100 text-green-700 rounded">
          {{ notification }}
        </div>
      </form>
    </div>
  </DefaultLayout>
</template>