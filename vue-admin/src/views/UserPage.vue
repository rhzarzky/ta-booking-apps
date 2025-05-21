<script setup>
import DefaultLayout from "@/layout/DefaultLayout.vue";
import AlertStatus from "@/components/alert/AlertStatus.vue";
import SkeltonLoader from "@/components/loading-skelton/SkeltonLoader.vue";
import { RouterLink, useRouter } from "vue-router";
import { ref, computed, onMounted, watch } from "vue";
import { useAuthStore } from "@/stores/auth";
import { fetchUsers, permissionApi } from "@/api/auth-api";
import SearchUser from "@/components/searchforms/SearchUser.vue";
import PaginationPage from "@/components/pagination/PaginationPage.vue";

const router = useRouter();
const users = ref([]);
const isLoading = ref(false);
const error = ref(null);
const currentPage = ref(1);
const usersPerPage = 10;
const authStore = useAuthStore();
const searchQuery = ref("");
const isVisible = ref(false);
const userPermissions = ref([]);
const userIdForPermissions = ref(null);
const showDeleteModal = ref(false);
const userToDelete = ref(null);

// Fetch Users
const fetchUserData = async () => {
  isLoading.value = true;
  try {
    const response = await fetchUsers();
    users.value = response.users;
  } catch (err) {
    error.value = "Failed to fetch users";
    console.error("Error fetching users:", err);
  } finally {
    isLoading.value = false;
  }
};

// filter users based on search query
const filteredUsers = computed(() => {
  const query = searchQuery.value.toLowerCase();
  return users.value.filter(user =>
    user.name.toLowerCase().includes(query) ||
    user.email.toLowerCase().includes(query)
  );
});

// Pagination
const totalPages = computed(() => {
  return Math.ceil(filteredUsers.value.length / usersPerPage);
});

const paginatedUsers = computed(() => {
  const start = (currentPage.value - 1) * usersPerPage;
  const end = start + usersPerPage;
  return filteredUsers.value.slice(start, end).sort((a, b) => a.name.localeCompare(b.name));
});

const handlePageChange = (page) => {
  currentPage.value = page;
};

const retryFetch = () => {
  fetchUserData();
};

// Delete User Confirmation
const confirmDelete = (id) => {
  userToDelete.value = id;
  showDeleteModal.value = true;
};

const handleDeleteConfirmed = async () => {
  try {
    await authStore.handleDeleteUser(userToDelete.value);
    users.value = users.value.filter(user => user.id !== userToDelete.value);
    authStore.showNotification("User deleted successfully.", "success");
  } catch (err) {
    console.error("Error deleting user:", err);
    authStore.showNotification("Failed to delete user.", "error");
  } finally {
    showDeleteModal.value = false;
    userToDelete.value = null;
  }
};

// Check if user has permission
const hasPermission = (permission) => {
  return authStore.currentPermission?.includes(permission);
};

// Checked Box Permission
const ontoggle = async (userId) => {
  isVisible.value = !isVisible.value;
  userIdForPermissions.value = userId;
  console.log("Available permissions:", authStore.currentPermission);

  if (isVisible.value) {
    try {
      const userData = await authStore.fetchUserWithPermissions(userId);
      userPermissions.value = userData.permission ? userData.permission : [];
      console.log("User permissions:", userPermissions.value);

    } catch (err) {
      console.error("Failed to fetch user permissions:", err);
    }
  } else {
    userPermissions.value = [];
    userIdForPermissions.value = null;
  }
};

// Save Permissions
const savePermissions = async () => {
  if (!userIdForPermissions.value) {
    authStore.showNotification("User ID is missing.", "error");
    return;
  }

  const updateData = {
    permissions: userPermissions.value,
  };

  try {
    await authStore.handleUpdateUser(userIdForPermissions.value, updateData);
    authStore.showNotification("Permissions updated successfully.", "success");
    isVisible.value = false;
    router.push("/user-list");
  } catch (err) {
    console.error("Error saving permissions:", err);
    authStore.showNotification("Failed to update permissions.", "error");
  }
};


onMounted(() => {
  if (!authStore.isLoggedIn) {
    router.push("/login");
  } else {
    fetchUserData();
    authStore.fetchPermissionApi();
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
        <AlertStatus :message="authStore.notification.message" :type="authStore.notification.type"
          :is-visible="authStore.notification.show" @close="authStore.notification.show = false" />
        <!-- Filter Search -->
        <SearchUser @search="searchQuery = $event" />
        <div class="flex flex-col md:flex-row gap-3 md:items-center">
          <!-- Add User Button -->
          <RouterLink to="/create-user"
            class="flex gap-2 items-center bg-gradient-to-b from-cobalt-700 to-cobalt-900 text-white text-sm md:text-base px-3 py-[6px] md:px-4 md:py-2 rounded-xl hover:shadow-md hover:shadow-cobalt-700/25 hover:transition hover:ease-in-out">
            Add User
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
          <h4 class="text-base md:text-xl font-bold text-cobalt-950">Managed User</h4>
        </div>
        <div class="overflow-x-auto">
          <table class="w-full table-auto border-collapse border-t border-b border-wildsand-200">
            <thead>
              <tr class="bg-wildsand-100 text-codgray-950 capitalize text-sm leading-normal">
                <th class="px-6 py-3 text-left font-semibold max-w-fit">ID</th>
                <th class="px-6 py-3 text-left font-semibold">Name</th>
                <th class="px-6 py-3 text-left font-semibold hidden sm:table-cell">Email</th>
                <th class="px-6 py-3 text-left font-semibold">Role</th>
                <th class="px-6 py-3 text-left font-semibold">Status</th>
                <th class="px-6 py-3 text-left font-semibold">Actions</th>
              </tr>
            </thead>
            <tbody class="text-codgray-800">
              <tr v-for="user in paginatedUsers" :key="user.id"
                class="border-t bg-white border-wildsand-200 hover:bg-wildsand-50/70">
                <td class="px-6 py-2 max-w-fit font-medium">{{ user.id }}</td>
                <td class="px-4 py-2">{{ user.name }}</td>
                <td class="px-4 py-2 hidden sm:table-cell">{{ user.email }}</td>
                <td class="px-4 py-2">
                  {{ Array.isArray(user.role) ? user.role.join(", ") : user.role }}
                </td>
                <td>
                  <span :class="{
                    'px-4 py-2 rounded-full text-sm size-fit': true,
                    'bg-green-100 text-green-600 border border-green-600': user.status === 'Active',
                    'bg-red-100 text-red-600 border border-red-600': user.status === 'Inactive',
                  }">
                    {{ user.status }}
                  </span>
                </td>

                <td class="flex items-center gap-6 py-4 px-1">
                  <button @click="confirmDelete(user.id)" title="Delete" class="text-red-500">
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
                        <p class="text-gray-600 mt-2">Are you sure you want to delete this user?</p>

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

                  <RouterLink title="Edit" :to="`/edit-profile/${user.id}`">
                    <!-- Edit Icon -->
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                      <path
                        d="M15 6L18 9M13 20H21M5 16L4 20L8 19L19.586 7.414C19.9609 7.03895 20.1716 6.53033 20.1716 6C20.1716 5.46967 19.9609 4.96106 19.586 4.586L19.414 4.414C19.0389 4.03906 18.5303 3.82843 18 3.82843C17.4697 3.82843 16.9611 4.03906 16.586 4.414L5 16Z"
                        stroke="#1858DD" stroke-linecap="round" stroke-linejoin="round" />
                    </svg>
                  </RouterLink>

                  <RouterLink title="Change Password" :to="`/change-password-user/${user.id}`">
                    <!-- Change Password Icon -->
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                      <path
                        d="M2 6.625C2 5.7962 2.32924 5.00134 2.91529 4.41529C3.50134 3.82924 4.2962 3.5 5.125 3.5H18.875C19.7038 3.5 20.4987 3.82924 21.0847 4.41529C21.6708 5.00134 22 5.7962 22 6.625V14.257C21.62 13.9432 21.1996 13.6818 20.75 13.48V6.625C20.75 6.12772 20.5525 5.65081 20.2008 5.29917C19.8492 4.94754 19.3723 4.75 18.875 4.75H5.125C4.62772 4.75 4.15081 4.94754 3.79917 5.29917C3.44754 5.65081 3.25 6.12772 3.25 6.625V14.375C3.25 14.8723 3.44754 15.3492 3.79917 15.7008C4.15081 16.0525 4.62772 16.25 5.125 16.25H11.952L13.202 17.5H5.125C4.2962 17.5 3.50134 17.1708 2.91529 16.5847C2.32924 15.9987 2 15.2038 2 14.375V6.625ZM16.625 12.5C16.4745 12.5 16.336 12.4465 16.228 12.3575C16.1939 12.1498 16.1191 11.9508 16.008 11.772C16.0324 11.626 16.1078 11.4934 16.2208 11.3979C16.3338 11.3023 16.477 11.2499 16.625 11.25H18.875C19.0408 11.25 19.1997 11.3158 19.3169 11.4331C19.4342 11.5503 19.5 11.7092 19.5 11.875C19.5 12.0408 19.4342 12.1997 19.3169 12.3169C19.1997 12.4342 19.0408 12.5 18.875 12.5H16.625ZM13.384 10.5L14.006 11.122C13.8074 11.2033 13.6271 11.3237 13.476 11.476L13.034 11.918L12.5 11.384L11.567 12.317C11.509 12.375 11.44 12.4211 11.3642 12.4525C11.2884 12.4839 11.2071 12.5001 11.125 12.5001C11.0429 12.5001 10.9616 12.4839 10.8858 12.4525C10.81 12.4211 10.741 12.375 10.683 12.317C10.625 12.259 10.5789 12.19 10.5475 12.1142C10.5161 12.0384 10.4999 11.9571 10.4999 11.875C10.4999 11.7929 10.5161 11.7116 10.5475 11.6358C10.5789 11.56 10.625 11.491 10.683 11.433L11.616 10.5L10.683 9.567C10.5658 9.44977 10.4999 9.29078 10.4999 9.125C10.4999 8.95922 10.5658 8.80023 10.683 8.683C10.8002 8.56577 10.9592 8.49992 11.125 8.49992C11.2908 8.49992 11.4498 8.56577 11.567 8.683L12.5 9.616L13.433 8.683C13.5502 8.56577 13.7092 8.49992 13.875 8.49992C14.0408 8.49992 14.1998 8.56577 14.317 8.683C14.4342 8.80023 14.5001 8.95922 14.5001 9.125C14.5001 9.29078 14.4342 9.44977 14.317 9.567L13.384 10.5ZM5.183 8.683C5.24104 8.62495 5.30995 8.57889 5.38578 8.54747C5.46162 8.51606 5.54291 8.49988 5.625 8.49988C5.70709 8.49988 5.78838 8.51606 5.86422 8.54747C5.94005 8.57889 6.00896 8.62495 6.067 8.683L7 9.616L7.933 8.683C8.05023 8.56577 8.20922 8.49992 8.375 8.49992C8.54078 8.49992 8.69977 8.56577 8.817 8.683C8.93423 8.80023 9.00008 8.95922 9.00008 9.125C9.00008 9.29078 8.93423 9.44977 8.817 9.567L7.884 10.5L8.817 11.433C8.87504 11.491 8.92109 11.56 8.9525 11.6358C8.98391 11.7116 9.00008 11.7929 9.00008 11.875C9.00008 11.9571 8.98391 12.0384 8.9525 12.1142C8.92109 12.19 8.87504 12.259 8.817 12.317C8.75896 12.375 8.69005 12.4211 8.61421 12.4525C8.53837 12.4839 8.45709 12.5001 8.375 12.5001C8.29291 12.5001 8.21163 12.4839 8.13579 12.4525C8.05995 12.4211 7.99104 12.375 7.933 12.317L7 11.384L6.067 12.317C5.94977 12.4342 5.79078 12.5001 5.625 12.5001C5.45922 12.5001 5.30023 12.4342 5.183 12.317C5.06577 12.1998 4.99992 12.0408 4.99992 11.875C4.99992 11.7092 5.06577 11.5502 5.183 11.433L6.116 10.5L5.183 9.567C5.12495 9.50896 5.07889 9.44005 5.04747 9.36421C5.01605 9.28838 4.99988 9.20709 4.99988 9.125C4.99988 9.04291 5.01605 8.96162 5.04747 8.88579C5.07889 8.80995 5.12495 8.74104 5.183 8.683ZM15.067 13.067C15.1842 12.9498 15.2501 12.7908 15.2501 12.625C15.2501 12.4592 15.1842 12.3002 15.067 12.183C14.9498 12.0658 14.7908 11.9999 14.625 11.9999C14.4592 11.9999 14.3002 12.0658 14.183 12.183L12.183 14.183C12.1249 14.241 12.0789 14.3099 12.0475 14.3858C12.0161 14.4616 11.9999 14.5429 11.9999 14.625C11.9999 14.7071 12.0161 14.7884 12.0475 14.8642C12.0789 14.9401 12.1249 15.009 12.183 15.067L14.183 17.067C14.3002 17.1842 14.4592 17.2501 14.625 17.2501C14.7908 17.2501 14.9498 17.1842 15.067 17.067C15.1842 16.9498 15.2501 16.7908 15.2501 16.625C15.2501 16.4592 15.1842 16.3002 15.067 16.183L14.134 15.25H18.5C19.1203 15.2501 19.7276 15.4277 20.2502 15.7618C20.7728 16.0959 21.1888 16.5725 21.4492 17.1355C21.7097 17.6984 21.8036 18.3242 21.7198 18.9387C21.6361 19.5533 21.3782 20.1311 20.9767 20.6039C20.5752 21.0767 20.0467 21.4246 19.4538 21.6068C18.8609 21.7889 18.2282 21.7975 17.6305 21.6317C17.0328 21.4658 16.4951 21.1324 16.0808 20.6707C15.6665 20.2091 15.393 19.6386 15.2925 19.0265C15.2793 18.9455 15.2503 18.8678 15.2071 18.798C15.1639 18.7282 15.1073 18.6676 15.0407 18.6197C14.9741 18.5717 14.8987 18.5373 14.8188 18.5185C14.7389 18.4997 14.656 18.4968 14.575 18.51C14.494 18.5232 14.4163 18.5522 14.3465 18.5954C14.2767 18.6386 14.2161 18.6952 14.1682 18.7618C14.1202 18.8284 14.0858 18.9038 14.067 18.9837C14.0482 19.0636 14.0453 19.1465 14.0585 19.2275C14.4065 21.367 16.262 23 18.5 23C19.6935 23 20.8381 22.5259 21.682 21.682C22.5259 20.8381 23 19.6935 23 18.5C23 17.3065 22.5259 16.1619 21.682 15.318C20.8381 14.4741 19.6935 14 18.5 14H14.134L15.067 13.067Z"
                        fill="#F4A700" />
                    </svg>
                  </RouterLink>

                  <!-- Access Control -->
                  <button type="button" @click="ontoggle(user.id)" title="Role Access Control">
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
                    <div class="bg-white rounded-lg shadow-lg p-6 w-full max-w-md relative">
                      <button @click="ontoggle(null)" class="absolute top-3 right-3 text-gray-600 hover:text-gray-900"
                        aria-label="Close modal">
                        &times;
                      </button>
                      <h3 id="modal-title" class="text-lg font-bold mb-4 text-cobalt-950">
                        Manage Permissions
                      </h3>

                      <form @submit.prevent="savePermissions">
                        <div class="max-h-60 overflow-y-auto mb-4 grid grid-cols-2 gap-x-6 gap-y-3">
                          <label v-for="permission in authStore.currentPermission" :key="permission"
                            class="inline-flex items-center gap-2 cursor-pointer">
                            <input type="checkbox" :value="permission" v-model="userPermissions"
                              :disabled="!hasPermission('assign permission')"
                              class="rounded border-gray-300 text-cobalt-700 focus:ring-cobalt-700" />
                            {{ permission }}
                          </label>
                        </div>

                        <div class="flex justify-end gap-3">
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