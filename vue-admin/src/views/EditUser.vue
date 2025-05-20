<script setup>
import DefaultLayout from "@/layout/DefaultLayout.vue";
import { ref, reactive, onMounted } from "vue";
import { useRouter, useRoute } from "vue-router";
import { useAuthStore } from "@/stores/auth";

const authStore = useAuthStore();
const router = useRouter();
const route = useRoute();
const userRoles = ref([]);

const post = reactive({
  name: "",
  email: "",
  role: "",
  status: "Active", // Default status
});

const notification = ref("");

// Function to fetch roles from API
onMounted(async () => {
  userRoles.value = await authStore.fetchRoleApi();
});

// Function to fetch user data by ID
const fetchUserData = async (userId) => {
  try {
    const userData = await authStore.handleGetUserById(userId);
    if (!userData || !userData.user) {
      throw new Error("User data is not available.");
    }

    // Setel nama dan email dari pengguna
    post.name = userData.user.name;
    post.email = userData.user.email;

    // Ambil role dari data pengguna yang ada
    const userRoleList = userData.user.role;

    // Atur default role jika pengguna memiliki role
    if (userRoleList.length > 0) {
      post.role = userRoleList.length === 1 ? userRoleList[0] : "";
    } else {
      post.role = "";
    }

    // Atur status pengguna
    post.status = userData.user.status;
  } catch (error) {
    console.error("Failed to fetch user data", error);
  }
};

onMounted(() => {
  const userId = route.params.id; // Get user ID from route parameters
  if (userId) {
    fetchUserData(userId); // Hanya panggil jika userId tidak undefined
  } else {
    notification.value = "Invalid user ID.";
  }
});

// Function to update user
const updateUser = async () => {
  const userData = {
    name: post.name,
    email: post.email,
    role: post.role,
    status: post.status,
  };
  try {
    await authStore.handleUpdateUser(route.params.id, userData);
    notification.value = "User updated successfully!";
    router.push("/users-list");
  } catch (error) {
    console.error("Error updating user:", error);
    notification.value = error.response?.data?.errors || {
      general: ["Update failed. Please check your input."],
    };
    if (error.response) {
      console.error("Response data:", error.response.data);
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
        <h2 class="text-codgray-900 md:text-2xl text-base font-semibold">
          Edit User Account
        </h2>
        <p class="md:text-base text-sm text-wildsand-400">
          Please fill in this field to proceed with updating the user.
        </p>
      </div>
      <form @submit.prevent="updateUser" class="flex flex-col gap-6">
        <div class="flex flex-col gap-2">
          <label class="text-sm md:text-base text-wildsand-600 flex gap-1" for="name">
            Name
            <span class="text-red-600">*</span>
          </label>
          <input
            class="w-full hover:border-cobalt-700 h-12 border border-wildsand-300 hover:bg-cobalt-50 focus:outline-none focus:ring-1 focus:ring-cobalt-700 text-codgray-900 rounded-md shadow-sm p-2 text-base placeholder-small"
            id="name" type="text" v-model="post.name" placeholder="Enter user name" />
        </div>

        <div class="flex flex-col gap-2">
          <label class="text-sm md:text-base text-wildsand-600 flex gap-1" for="email">
            Email
            <span class="text-red-600">*</span>
          </label>
          <input
            class="w-full hover:border-cobalt-700 h-12 border border-wildsand-300 hover:bg-cobalt-50 focus:outline-none focus:ring-1 focus:ring-cobalt-700 text-codgray-900 rounded-md shadow-sm p-2 text-base placeholder-small"
            id="email" type="email" v-model="post.email" placeholder="Enter user email" />
        </div>

        <div class="flex flex-col gap-2">
          <label class="text-sm md:text-base text-wildsand-600 flex gap-1" for="role">
            Role <span class="text-red-600">*</span>
          </label>
          <select id="role"
            class="w-full h-12 border border-wildsand-300 hover:bg-cobalt-50 focus:outline-none focus:ring-1 focus:ring-cobalt-700 text-codgray-900 rounded-md shadow-sm p-2 text-base"
            v-model="post.role">
            <option value="" disabled>Select a role</option>
            <option v-for="role in userRoles" :key="role.id" :value="role.name">
              {{ role.name }}
            </option>
          </select>
        </div>


        <div class="flex flex-col gap-2">
          <label class="text-sm md:text-base text-wildsand-600 flex gap-1" for="status">
            Status <span class="text-red-600">*</span>
          </label>
          <select id="status"
            class="w-full h-12 border border-wildsand-300 hover:bg-cobalt-50 focus:outline-none focus:ring-1 focus:ring-cobalt-700 text-codgray-900 rounded-md shadow-sm p-2 text-base"
            v-model="post.status">
            <option value="Active">Active</option>
            <option value="Inactive">Inactive</option>
          </select>
        </div>

        <div class="justify-end flex w-full gap-3">
          <button type="button"
            class="md:px-6 md:py-3 px-4 max-w-fit font-semibold py-2 text-cobalt-800 rounded-xl w-36 hover:bg-cobalt-50 border-cobalt-800 border-2"
            @click="cancel">
            Cancel
          </button>
          <button type="submit"
            class="md:px-6 md:py-3 px-4 max-w-fit font-semibold py-2 bg-gradient-to-b from-cobalt-700 to-cobalt-900 text-white rounded-xl w-36">
            Save
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