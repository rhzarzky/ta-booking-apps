<script setup>
import DefaultLayout from "@/layout/DefaultLayout.vue";
import AlertStatus from "@/components/alert/AlertStatus.vue";
import { useRouter, useRoute } from "vue-router";
import { ref, onMounted, computed } from "vue";
import { useAuthStore } from "@/stores/auth";
import { useRoleStore } from "@/stores/role";

const router = useRouter();
const route = useRoute();
const authStore = useAuthStore();
const roleStore = useRoleStore();

const post = ref({
  name: "",
  permissions: [],
});
const validation = ref({});
const roleId = route.params.id;

const groupedPermissions = computed(() => {
  const groups = {};
  if (Array.isArray(authStore.currentPermission)) {
    authStore.currentPermission.forEach((permission) => {
      const parts = permission.trim().split(" ");
      if (parts.length >= 2) {
        const group = parts[parts.length - 1];
        if (!groups[group]) {
          groups[group] = [];
        }
        groups[group].push(permission);
      }
    });
  }
  return groups;
});

const isAllGroupChecked = (groupName) => {
  const groupPermissions = groupedPermissions.value[groupName];
  return (
    Array.isArray(post.value.permissions) &&
    groupPermissions.every((permission) =>
      post.value.permissions.includes(permission)
    )
  );
};

const toggleGroup = (groupName) => {
  const groupPermissions = groupedPermissions.value[groupName];
  const allSelected = isAllGroupChecked(groupName);

  if (allSelected) {
    post.value.permissions = post.value.permissions.filter(
      (permission) => !groupPermissions.includes(permission)
    );
  } else {
    const updated = new Set(post.value.permissions);
    groupPermissions.forEach((p) => updated.add(p));
    post.value.permissions = [...updated];
  }
};

const isAllGroupsChecked = computed(() => {
  const allPermissions = Object.values(groupedPermissions.value).flat();
  return allPermissions.every((permission) =>
    post.value.permissions.includes(permission)
  );
});

const toggleAllGroups = () => {
  const allPermissions = Object.values(groupedPermissions.value).flat();
  const allSelected = isAllGroupsChecked.value;

  if (allSelected) {
    post.value.permissions = post.value.permissions.filter(
      (permission) => !allPermissions.includes(permission)
    );
  } else {
    const updated = new Set(post.value.permissions);
    allPermissions.forEach((p) => updated.add(p));
    post.value.permissions = [...updated];
  }
};

const hasPermission = (permission) => {
  return authStore.currentPermission?.includes(permission);
};

// Fetch role data by ID
const fetchRole = async () => {
  try {
    const role = await roleStore.fetchPermissionRoleApi(roleId);
    post.value.name = role.name;
    post.value.permissions = role.permissions || [];
    console.log("Set post.permissions:", post.value.permissions);
  } catch (error) {
    roleStore.showNotification("Failed to fetch role data", "error");
  }
};

// Save updated role
const store = async () => {
  try {
    const payload = {
      name: post.value.name,
      permissions: post.value.permissions,
    };
    await roleStore.handleEditRole(roleId, payload);
    roleStore.showNotification("Role updated successfully", "success");
    router.push("/role-list");
  } catch (error) {
    if (error.response?.data?.errors) {
      validation.value = error.response.data.errors;
    } else {
      roleStore.showNotification(error.response.data.message, "error");
    }
  }
};

// Cancel button
const cancel = () => {
  router.push("/role-list");
};

onMounted(async () => {
  await fetchRole();
});
</script>

<template>
  <DefaultLayout class="bg-whiteBgPrimary-100">
    <div class="max-h-fit md:p-9 p-4 flex flex-col gap-6 bg-white rounded-2xl">
      <div class="flex flex-col gap-1">
        <AlertStatus :message="roleStore.notification.message" :type="roleStore.notification.type"
          :is-visible="roleStore.notification.show" @close="roleStore.notification.show = false" />
        <h2 class="text-codgray-900 md:text-2xl text-base font-semibold">
          Edit Role Name
        </h2>
      </div>

      <form @submit.prevent="store" class="flex flex-col gap-6">
        <div class="flex flex-col gap-2">
          <!-- Role Name -->
          <label class="text-sm md:text-base text-wildsand-600 flex gap-1" for="name">
            Role Name <span class="text-red-600">*</span>
          </label>
          <input id="name" type="text" v-model="post.name" placeholder="Enter role name"
            class="w-full h-12 border border-wildsand-300 hover:border-cobalt-700 hover:bg-cobalt-50 focus:outline-none focus:ring-1 focus:ring-cobalt-700 text-codgray-900 rounded-md shadow-sm p-2 text-base placeholder-small" />
          <div class="mt-2 text-red-600" v-if="validation.name">
            {{ validation.name[0] }}
          </div>

          <!-- Permissions -->
          <label class="text-sm md:text-base text-wildsand-600" for="permissions">Permissions</label>

          <!-- Select All Groups -->
          <div class="flex justify-end mb-2" v-if="authStore.currentPermission?.length">
            <label class="flex items-center gap-2 text-sm cursor-pointer">
              <input type="checkbox" :checked="isAllGroupsChecked" @change="toggleAllGroups"
                class="rounded border-gray-300 text-cobalt-700 focus:ring-cobalt-700"
                :disabled="!hasPermission('assign permission')" />
              Select All Groups
            </label>
          </div>

          <!-- Grouped Permissions -->
          <div v-if="authStore.currentPermission?.length" class="max-h-[60vh] overflow-y-auto mb-4">
            <div v-for="(permissions, group) in groupedPermissions" :key="group" class="mb-4">
              <!-- Group Header -->
              <div class="flex items-center justify-between mb-1">
                <h4 class="text-sm font-semibold capitalize text-wildsand-600">{{ group }}</h4>
                <label class="flex items-center gap-2 text-sm cursor-pointer">
                  <input type="checkbox" :checked="isAllGroupChecked(group)" @change="toggleGroup(group)"
                    class="rounded border-gray-300 text-cobalt-700 focus:ring-cobalt-700"
                    :disabled="!hasPermission('assign permission')" />
                  Select All
                </label>
              </div>

              <!-- Permissions in Group -->
              <div class="grid grid-cols-2 gap-x-6 gap-y-3 pl-2">
                <label v-for="permission in permissions" :key="permission"
                  class="inline-flex items-center gap-2 text-sm cursor-pointer">
                  <input type="checkbox" :value="permission" v-model="post.permissions"
                    :disabled="!hasPermission('assign permission')"
                    class="rounded border-gray-300 text-cobalt-700 focus:ring-cobalt-700" />
                  {{ permission }}
                </label>
              </div>
            </div>
          </div>

          <!-- Jika Tidak Ada Data Permission -->
          <div v-else class="text-sm text-gray-500">No permission data available.</div>

          <!-- Action Buttons -->
          <div class="flex justify-end gap-4">
            <button type="button" @click="cancel"
              class="md:px-6 md:py-3 px-4 font-semibold py-2 bg-gray-200 text-gray-700 rounded-xl w-36 hover:bg-gray-300">
              Cancel
            </button>
            <button type="submit"
              class="md:px-6 md:py-3 px-4 font-semibold py-2 bg-gradient-to-b from-cobalt-700 to-cobalt-900 text-white rounded-xl w-36">
              Save
            </button>
          </div>
        </div>
      </form>
    </div>
  </DefaultLayout>
</template>
