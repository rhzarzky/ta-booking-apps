<script setup>
import { reactive, ref } from "vue";
import { useRouter } from "vue-router";
import DefaultLayout from "@/layout/DefaultLayout.vue";
import { useAuthStore } from "@/stores/auth";
import { useRoleStore } from "@/stores/role";
import AlertStatus from "@/components/alert/AlertStatus.vue";

const authStore = useAuthStore();
const roleStore = useRoleStore();
const router = useRouter();

// Check if user has permission
const hasPermission = (permission) => {
  return authStore.currentPermission?.includes(permission);
};

const post = reactive({
  name: "",
  permissions: [],
});

const validation = ref({});
const notification = ref("");

const store = async () => {
  const roleData = {
    name: post.name,
    permissions: post.permissions,
  };
  try {
    await roleStore.handleCreateRole(roleData);
    roleStore.showNotification("Role created successfully.", "success");
    router.push("/role-list");
  } catch (error) {
    console.error("Error creating role:", error);
    roleStore.showNotification(error.response?.data?.message || "Failed to create role.", "error");
    if (error.response) {
      validation.value = error.response.data.message || {};
    }
  }
};

// Fungsi untuk tombol Cancel
const cancel = () => {
  router.push({ path: "/role-list" });
};
</script>

<template>
  <DefaultLayout class="bg-whiteBgPrimary-100">
    <div class="max-h-fit md:p-9 p-4 flex flex-col gap-6 bg-white rounded-2xl">
      <div class="flex flex-col gap-1">
        <!-- Notification -->
        <AlertStatus :message="roleStore.notification.message" :type="roleStore.notification.type"
          :is-visible="roleStore.notification.show" @close="roleStore.notification.show = false" />
        <h2 class="text-codgray-900 md:text-2xl text-base font-semibold">
          Create Role Name
        </h2>
      </div>
      <form @submit.prevent="store" class="flex flex-col gap-6">
        <div class="flex flex-col gap-2">
          <label class="text-sm md:text-base text-wildsand-600 flex gap-1" for="name">Role Name
            <span class="text-red-600">*</span>
          </label>
          <input
            class="w-full hover:border-cobalt-700 h-12 border border-wildsand-300 hover:bg-cobalt-50 focus:outline-none focus:ring-1 focus:ring-cobalt-700 text-codgray-900 rounded-md shadow-sm p-2 text-base placeholder-small"
            id="name" placeholder="Enter user name" type="text" v-model="post.name" />
          <!-- validation -->
          <div class="mt-2 text-red-600" v-if="validation.value?.name">
            {{ validation.value.name[0] }}
          </div>
          <label class="text-sm md:text-base text-wildsand-600 flex gap-1" for="permissions">Permissions
          </label>
          <div class="max-h-60 overflow-y-auto mb-4 grid grid-cols-2 gap-x-6 gap-y-3">
            <label v-for="permission in authStore.currentPermission" :key="permission"
              class="inline-flex items-center gap-2 cursor-pointer">
              <input type="checkbox" :value="permission" v-model="post.permissions"
                :disabled="!hasPermission('assign permission')"
                class="rounded border-gray-300 text-cobalt-700 focus:ring-cobalt-700" />
              {{ permission }}
            </label>
          </div>
        </div>

        <div class="justify-end flex w-full gap-4">
          <!-- Tombol Cancel -->
          <button type="button"
            class="md:px-6 md:py-3 px-4 max-w-fit font-semibold py-2 bg-gray-200 text-gray-700 rounded-xl w-36 hover:bg-gray-300"
            @click="cancel">
            Cancel
          </button>
          <!-- Tombol Create Role -->
          <button type="submit"
            class="md:px-6 md:py-3 px-4 max-w-fit font-semibold py-2 bg-gradient-to-b from-cobalt-700 to-cobalt-900 text-white rounded-xl w-36">
            Create Role
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