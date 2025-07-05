<script setup>
import DefaultLayout from "@/layout/DefaultLayout.vue";
import AlertStatus from "@/components/alert/AlertStatus.vue";
import SkeltonLoader from "@/components/loading-skelton/SkeltonLoader.vue";
import { RouterLink, useRouter } from "vue-router";
import { ref, computed, onMounted, watch } from "vue";
import { useAuthStore } from "@/stores/auth";
import { useRoleStore } from "@/stores/role";
import PaginationPage from "@/components/pagination/PaginationPage.vue";
import { roleApi } from "@/api/role-api";
import { fetchUsers } from "@/api/auth-api";

const router = useRouter();
const isLoading = ref(false);
const error = ref(null);
const currentPage = ref(1);
const rolesPerPage = 10;
const authStore = useAuthStore();
const roleStore = useRoleStore();
const users = ref([]);
const roles = ref([]);
const searchQuery = ref("");
const isVisible = ref(false);
const rolePermissions = ref([]);
const roleIdForPermissions = ref(null);
const showDeleteModal = ref(false);
const roleToDelete = ref(null);
const roleNameForPermissions = ref("");

// Fetch Roles
const fetchRoleData = async () => {
  isLoading.value = true;
  try {
    const response = await roleApi();
    console.log("Fetched roles response:", response);

    // Pastikan response adalah array
    if (Array.isArray(response)) {
      roles.value = response;
    } else if (Array.isArray(response.roles)) {
      roles.value = response.roles;
    } else {
      throw new Error("Invalid response format for roles");
    }
  } catch (err) {
    error.value = "Failed to fetch roles";
    console.error("Error fetching roles:", err);
  } finally {
    isLoading.value = false;
  }
};

// Filter roles based on search query
const filteredRoles = computed(() => {
  const query = searchQuery.value.toLowerCase();
  return Array.isArray(roles.value)
    ? roles.value.filter(role => role.name.toLowerCase().includes(query))
    : [];
});

// Pagination
const totalPages = computed(() => {
  return Math.ceil(filteredRoles.value.length / rolesPerPage);
});

const hasNextPage = computed(() => currentPage.value < totalPages.value);
const hasPrevPage = computed(() => currentPage.value > 1);

const paginatedRoles = computed(() => {
  const start = (currentPage.value - 1) * rolesPerPage;
  const end = start + rolesPerPage;
  return filteredRoles.value.slice(start, end).sort((a, b) => a.id - b.id);
});

const handlePageChange = (page) => {
  currentPage.value = page;
};

const retryFetch = () => {
  fetchUsers();
  fetchRoleData();
};

// Delete Role Confirmation
const confirmDelete = (id) => {
  roleToDelete.value = id;
  showDeleteModal.value = true;
};

const handleDeleteConfirmed = async () => {
  try {
    await roleStore.handleDeleteRole(roleToDelete.value);
    await fetchRoleData();
    roleStore.showNotification("Role deleted successfully.", "success");
  } catch (err) {
    console.error("Error deleting role:", err);
    roleStore.showNotification(err.response?.data?.message || "Delete failed", "error");
  } finally {
    showDeleteModal.value = false;
    roleToDelete.value = null;
  }
};

// Check if user has permission
const hasPermission = (permission) => {
  return authStore.currentPermission?.includes(permission);
};

// Checked Box Permission
const ontoggle = async (roleId, roleName = "") => {
  if (!hasPermission("show permission")) {
    roleStore.showNotification("You do not have the required authorization.", "error");
    return;
  }
  isVisible.value = !isVisible.value;
  roleIdForPermissions.value = roleId;
  roleNameForPermissions.value = roleName;

  if (isVisible.value && roleId) {
    try {
      const roleData = await roleStore.fetchPermissionRoleApi(roleId);
      rolePermissions.value = roleData.permissions || [];
    } catch (err) {
      console.error("Failed to fetch role permissions:", err);
      rolePermissions.value = [];
    }
  }
};

// Group permissions based on the last word
const groupedPermissions = computed(() => {
  const groups = {};

  authStore.currentPermission.forEach((permission) => {
    const parts = permission.trim().split(" ");
    if (parts.length >= 2) {
      const group = parts[parts.length - 1]; // take the last word
      if (!groups[group]) {
        groups[group] = [];
      }
      groups[group].push(permission);
    }
  });

  return groups;
});

// Check if all permissions in the group are checked
const isAllGroupsChecked = computed(() => {
  const allPermissions = Object.values(groupedPermissions.value).flat();
  return allPermissions.every((permission) =>
    rolePermissions.value.includes(permission)
  );
});

const isAllGroupChecked = (groupName) => {
  const groupPermissions = groupedPermissions.value[groupName];
  return groupPermissions.every((permission) =>
    rolePermissions.value.includes(permission)
  );
};

// // Toggle all grup (global)
const toggleAllGroups = () => {
  const allPermissions = Object.values(groupedPermissions.value).flat();
  const allSelected = isAllGroupsChecked.value;

  if (allSelected) {
    rolePermissions.value = rolePermissions.value.filter(
      (permission) => !allPermissions.includes(permission)
    );
  } else {
    const updatedPermissions = new Set(rolePermissions.value);
    allPermissions.forEach((permission) => updatedPermissions.add(permission));
    rolePermissions.value = [...updatedPermissions];
  }
};

// Toggle all permissions in the group
const toggleGroup = (groupName) => {
  const groupPermissions = groupedPermissions.value[groupName];
  const allSelected = isAllGroupChecked(groupName);

  if (allSelected) {
    // Uncheck all
    rolePermissions.value = rolePermissions.value.filter(
      (permission) => !groupPermissions.includes(permission)
    );
  } else {
    // Add missing ones
    groupPermissions.forEach((permission) => {
      if (!rolePermissions.value.includes(permission)) {
        rolePermissions.value.push(permission);
      }
    });
  }
};

// Save Permissions to Role
const savePermissions = async () => {
  if (!roleIdForPermissions.value) {
    roleStore.showNotification("Role ID is missing.", "error");
    return;
  }
  try {
    await roleStore.assignPermissionToRole(roleIdForPermissions.value, rolePermissions.value);
    roleStore.showNotification("Permissions updated successfully.", "success");
    isVisible.value = false;
    await fetchRoleData();
  } catch (err) {
    console.error("Error saving permissions:", err);
    roleStore.showNotification(err.response?.data?.message || "Failed to update permissions.", "error");
    isVisible.value = false;
  }
};

onMounted(() => {
  if (!authStore.isLoggedIn) {
    router.push("/login");
  } else {
    fetchRoleData();
  }
});

// Reset to page 1 when search query changes
watch(searchQuery, () => {
  currentPage.value = 1;
});
</script>

<template>
  <DefaultLayout class="bg-whiteBgPrimary-100">
    <div class="min-h-screen flex flex-col gap-4 rounded-2xl bg-white p-4 md:p-8">
      <div class="w-full flex gap-3 items-center">
        <!-- Notification -->
        <AlertStatus :message="roleStore.notification.message" :type="roleStore.notification.type"
          :is-visible="roleStore.notification.show" @close="roleStore.notification.show = false" />

        <!-- Search -->
        <input v-model="searchQuery" type="text" placeholder="Search Role"
          class="flex-1 min-w-0 px-4 py-2 border md:border-2 border-wildsand-200 rounded-lg text-codgray-900 font-medium cursor-pointer focus:outline-none focus:ring-2 focus:ring-offset-2 focus:text-cobalt-700 focus:ring-cobalt-600 hover:border-cobalt-500 transition-colors duration-200 text-sm md:text-base ease-in-out" />
        <div class="flex flex-col md:flex-row gap-3 md:items-center">
          <RouterLink to="/create-role"
            class="flex gap-2 items-center bg-gradient-to-b from-cobalt-700 to-cobalt-900 text-white text-sm md:text-base px-3 py-[6px] md:px-4 md:py-2 rounded-xl hover:shadow-md hover:shadow-cobalt-700/25 hover:transition hover:ease-in-out">
            Create Role
            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24">
              <path fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"
                d="M18 12h-6m0 0H6m6 0V6m0 6v6" />
            </svg>
          </RouterLink>
        </div>
      </div>

      <SkeltonLoader v-if="isLoading" :rows="5" :columns="6" type="table" size="medium" />
      <div v-else-if="error" class="py-8 text-center" role="alert">
        <div class="text-red-500 mb-4">{{ error }}</div>
        <button @click="retryFetch"
          class="px-4 py-2 bg-blue-500 text-white rounded-md hover:bg-blue-600 transition-colors">
          Retry
        </button>
      </div>

      <div v-else class="rounded-xl border border-wildsand-200 bg-white shadow-lg shadow-wildsand-100">
        <div class="py-6 px-4 md:px-6 xl:px-7">
          <h4 class="text-base md:text-xl font-bold text-cobalt-950">Managed Role</h4>
        </div>
        <div class="overflow-x-auto">
          <table class="w-full table-auto border-collapse border-t border-b border-wildsand-200">
            <thead>
              <tr class="bg-wildsand-100 text-codgray-950 capitalize text-sm leading-normal">
                <th class="px-6 py-3 text-left font-semibold max-w-fit">No.</th>
                <th class="px-6 py-3 text-left font-semibold">Role Name</th>
                <th class="px-6 py-3 text-left font-semibold">Actions</th>
              </tr>
            </thead>
            <tbody class="text-codgray-800">
              <tr v-for="role in paginatedRoles" :key="role.id"
                class="border-t bg-white border-wildsand-200 hover:bg-wildsand-50/70">
                <td class="px-6 py-2 max-w-fit font-medium">{{ (currentPage - 1) * rolesPerPage +
                  (paginatedRoles.indexOf(role) + 1) }}</td>
                <td class="px-4 py-2">{{ role.name }}</td>
                <td class="flex items-center gap-6 py-4 px-1">
                  <button @click="confirmDelete(role.id)" title="Delete" class="text-red-500">
                    <!-- Delete Icon -->
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                      <path
                        d="M18 9L17.16 17.398C17.033 18.671 16.97 19.307 16.68 19.788C16.4257 20.2114 16.0516 20.55 15.605 20.761C15.098 21 14.46 21 13.18 21H10.82C9.541 21 8.902 21 8.395 20.76C7.94805 20.5491 7.57361 20.2106 7.319 19.787C7.031 19.307 6.967 18.671 6.839 17.398L6 9M13.5 15.5V10.5M10.5 15.5V10.5M4.5 6.5H9.115M9.115 6.5L9.501 3.828C9.613 3.342 10.017 3 10.481 3H13.519C13.983 3 14.386 3.342 14.499 3.828L14.885 6.5M9.115 6.5H14.885M14.885 6.5H19.5"
                        stroke="#E20E0E" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" />
                    </svg>
                  </button>
                  <transition name="fade">
                    <div v-if="showDeleteModal"
                      class="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50">
                      <div class="bg-white p-6 rounded-lg w-full max-w-md shadow-lg">
                        <h2 class="text-lg font-semibold text-gray-800">Confirm Delete</h2>
                        <p class="text-gray-600 mt-2">Are you sure you want to delete this role?</p>

                        <div class="mt-4 flex justify-end gap-2">
                          <button @click="showDeleteModal = false"
                            class="px-4 py-2 text-sm bg-gray-200 rounded hover:bg-gray-300">
                            Cancel
                          </button>
                          <button @click="handleDeleteConfirmed"
                            class="px-4 py-2 text-sm bg-red-600 text-white rounded hover:bg-red-700">
                            Delete
                          </button>
                        </div>
                      </div>
                    </div>
                  </transition>

                  <RouterLink title="Edit" :to="`/edit-role/${role.id}`">
                    <!-- Edit Icon -->
                    <svg width=" 24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                      <path
                        d="M15 6L18 9M13 20H21M5 16L4 20L8 19L19.586 7.414C19.9609 7.03895 20.1716 6.53033 20.1716 6C20.1716 5.46967 19.9609 4.96106 19.586 4.586L19.414 4.414C19.0389 4.03906 18.5303 3.82843 18 3.82843C17.4697 3.82843 16.9611 4.03906 16.586 4.414L5 16Z"
                        stroke="#1858DD" stroke-linecap="round" stroke-linejoin="round" />
                    </svg>
                  </RouterLink>

                  <!-- Access Control -->
                  <button type="button" @click="ontoggle(role.id, role.name)" title="Role Access Control">
                    <svg xmlns="http://www.w3.org/2000/svg" width="24px" height="24px" viewBox="0 0 24 24"
                      class="text-green-900">
                      <g fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"
                        stroke-width="1.5">
                        <path
                          d="M12 22c5.523 0 10-4.477 10-10S17.523 2 12 2S2 6.477 2 12s4.477 10 10 10M7 9l5 1m5-1l-5 1m0 0v3m0 0l-2 5m2-5l2 5" />
                        <path fill="currentColor" d="M12 7a.5.5 0 1 1 0-1a.5.5 0 0 1 0 1" />
                      </g>
                    </svg>
                  </button>

                  <!-- Permissions Modal -->
                  <div v-if="isVisible"
                    class="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50" aria-modal="true"
                    role="dialog" aria-labelledby="modal-title">
                    <div class="bg-white rounded-lg shadow-lg p-6 w-full max-w-xl relative">
                      <button @click="ontoggle(null)" class="absolute top-3 right-3 text-gray-600 hover:text-gray-900"
                        aria-label="Close modal">&times; </button>

                      <h3 id="modal-title" class="text-lg font-bold mb-4 text-cobalt-950">
                        Manage Permissions for Role: {{ roleNameForPermissions }}
                      </h3>

                      <form @submit.prevent="savePermissions">
                        <!-- Select All Groups -->
                        <div class="flex left-end mb-4">
                          <label class="flex items-center gap-2 text-sm cursor-pointer">
                            <input type="checkbox" :checked="isAllGroupsChecked" @change="toggleAllGroups"
                              class="rounded border-gray-300 text-cobalt-700 focus:ring-cobalt-700"
                              :disabled="!hasPermission('assign permission')" />
                            Select All Groups
                          </label>
                        </div>

                        <!-- Loop Per Group -->
                        <div v-for="(permissions, group) in groupedPermissions" :key="group" class="mb-4 border-b pb-3">
                          <!-- Select All Checkbox -->
                          <div class="flex items-center justify-between mb-2">
                            <h4 class="font-semibold capitalize text-cobalt-800">{{ group }}</h4>
                            <label class="flex items-center gap-2 text-sm cursor-pointer">
                              <input type="checkbox" :checked="isAllGroupChecked(group)" @change="toggleGroup(group)"
                                class="rounded border-gray-300 text-cobalt-700 focus:ring-cobalt-700"
                                :disabled="!hasPermission('assign permission')" />
                              Select All
                            </label>
                          </div>

                          <!-- Permissions in Group -->
                          <div class="grid grid-cols-2 gap-2">
                            <label v-for="permission in permissions" :key="permission"
                              class="flex items-center gap-2 text-sm cursor-pointer">
                              <input type="checkbox" :value="permission" v-model="rolePermissions"
                                class="rounded border-gray-300 text-cobalt-700 focus:ring-cobalt-700"
                                :disabled="!hasPermission('assign permission')" />
                              {{ permission }}
                            </label>
                          </div>
                        </div>

                        <!-- Buttons -->
                        <div class="flex justify-end gap-3 mt-6">
                          <button type="button" @click="ontoggle(null)"
                            class="px-4 py-2 bg-gray-300 text-gray-700 rounded hover:bg-gray-400">
                            Cancel
                          </button>
                          <button type="submit" :disabled="!hasPermission('assign permission')"
                            class="px-4 py-2 bg-cobalt-700 text-white rounded hover:bg-cobalt-800 disabled:opacity-50">
                            Save
                          </button>
                        </div>
                      </form>
                    </div>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
        <!-- Pagination Controls -->
        <PaginationPage :current-page="currentPage" :total-pages="totalPages" :has-next-page="hasNextPage"
          :has-prev-page="hasPrevPage" @page-change="handlePageChange" />
      </div>
    </div>
  </DefaultLayout>
</template>