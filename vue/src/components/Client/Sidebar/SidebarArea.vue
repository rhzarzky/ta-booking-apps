SidebarArea.vue
<template>
  <div class="sidebar bg-white text-gray-800 w-64 min-h-screen p-4 shadow-lg">
    <div class="flex items-center justify-center mb-8">
      <img src="@/assets/images/Appointly.png" alt="Appointly Logo" class="w-100 h-10" />
    </div>
    <ul>
      <li class="mb-5">
        <router-link
          to="/client/dashboard"
          class="flex items-center p-2 rounded text-gray-400"
          :class="{ 'bg-primary-gradient': isActive('/client/dashboard') }"
        >
          <span class="mr-2">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              width="16"
              height="16"
              fill="currentColor"
              class="bi bi-grid"
              viewBox="0 0 16 16"
            >
              <path
                d="M1 2.5A1.5 1.5 0 0 1 2.5 1h3A1.5 1.5 0 0 1 7 2.5v3A1.5 1.5 0 0 1 5.5 7h-3A1.5 1.5 0 0 1 1 5.5zM2.5 2a.5.5 0 0 0-.5.5v3a.5.5 0 0 0 .5.5h3a.5.5 0 0 0 .5-.5v-3a.5.5 0 0 0-.5-.5zm6.5.5A1.5 1.5 0 0 1 10.5 1h3A1.5 1.5 0 0 1 15 2.5v3A1.5 1.5 0 0 1 13.5 7h-3A1.5 1.5 0 0 1 9 5.5zm1.5-.5a.5.5 0 0 0-.5.5v3a.5.5 0 0 0 .5.5h3a.5.5 0 0 0 .5-.5v-3a.5.5 0 0 0-.5-.5zM1 10.5A1.5 1.5 0 0 1 2.5 9h3A1.5 1.5 0 0 1 7 10.5v3A1.5 1.5 0 0 1 5.5 15h-3A1.5 1.5 0 0 1 1 13.5zm1.5-.5a.5.5 0 0 0-.5.5v3a.5.5 0 0 0 .5.5h3a.5.5 0 0 0 .5-.5v-3a.5.5 0 0 0-.5-.5zm6.5.5A1.5 1.5 0 0 1 10.5 9h3a1.5 1.5 0 0 1 1.5 1.5v3a1.5 1.5 0 0 1-1.5 1.5h-3A1.5 1.5 0 0 1 9 13.5zm1.5-.5a.5.5 0 0 0-.5.5v3a.5.5 0 0 0 .5.5h3a.5.5 0 0 0 .5-.5v-3a.5.5 0 0 0-.5-.5z"
              />
            </svg>
          </span>
          Dashboard
        </router-link>
      </li>
      <li class="mb-5">
        <router-link
          to="/client/meeting"
          class="flex items-center p-2 rounded text-gray-400"
          :class="{ 'bg-primary-gradient': isActive('/client/meeting') }"
        >
          <span class="mr-2">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              width="16"
              height="16"
              fill="currentColor"
              class="bi bi-calendar"
              viewBox="0 0 16 16"
            >
              <path
                d="M3.5 0a.5.5 0 0 1 .5.5V1h8V.5a.5.5 0 0 1 1 0V1h1a2 2 0 0 1 2 2v11a2 2 0 0 1-2 2H2a2 2 0 0 1-2-2V3a2 2 0 0 1 2-2h1V.5a.5.5 0 0 1 .5-.5M1 4v10a1 1 0 0 0 1 1h12a1 1 0 0 0 1-1V4z"
              />
            </svg>
          </span>
          Meetings
        </router-link>
      </li>
      <li class="mb-5">
        <router-link
          to="/client/activity"
          class="flex items-center p-2 rounded text-gray-400"
          :class="{ 'bg-primary-gradient': isActive('/client/activity') }"
        >
          <span class="material-symbols-outlined mr-2">Activity</span> 
        </router-link>
      </li>
      <li class="mb-5">
        <router-link
          to="/client/profile"
          class="flex items-center p-2 rounded text-gray-400"
          :class="{ 'bg-primary-gradient': isActive('/client/profile') }"
        >
          <span class="mr-2">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              width="16"
              height="16"
              fill="currentColor"
              class="bi bi-person"
              viewBox="0 0 16 16"
            >
              <path
                d="M8 8a3 3 0 1 0 0-6 3 3 0 0 0 0 6m2-3a2 2 0 1 1-4 0 2 2 0 0 1 4 0m4 8c0 1-1 1-1 1H3s-1 0-1-1 1-4 6-4 6 3 6 4m-1-.004c-.001-.246-.154-.986-.832-1.664C11.516 10.68 10.289 10 8 10s-3.516.68-4.168 1.332c-.678.678-.83 1.418-.832 1.664z"
              />
            </svg>
          </span>
          Profile
        </router-link>
      </li>
      <li class="mt-8">
        <button
          @click="handleLogout"
          class="w-full text-red-600 font-semibold p-2 rounded hover:bg-gray-200 flex items-center"
        >
          <span class="mr-2">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              width="16"
              height="16"
              fill="currentColor"
              class="bi bi-box-arrow-left"
              viewBox="0 0 16 16"
            >
              <path
                fill-rule="evenodd"
                d="M6 12.5a.5.5 0 0 0 .5.5h8a.5.5 0 0 0 .5-.5v-9a.5.5 0 0 0-.5-.5h-8a.5.5 0 0 0-.5.5v2a.5.5 0 0 1-1 0v-2A1.5 1.5 0 0 1 6.5 2h8A1.5 1.5 0 0 1 16 3.5v9a1.5 1.5 0 0 1-1.5 1.5h-8A1.5 1.5 0 0 1 5 12.5v-2a.5.5 0 0 1 1 0z"
              />
              <path
                fill-rule="evenodd"
                d="M.146 8.354a.5.5 0 0 1 0-.708l3-3a.5.5 0 1 1 .708.708L1.707 7.5H10.5a.5.5 0 0 1 0 1H1.707l2.147 2.146a.5.5 0 0 1-.708.708z"
              />
            </svg>
          </span>
          Logout
        </button>
      </li>
    </ul>
  </div>
</template>

<script>
import { logout } from '/api/auth-api'

export default {
  name: 'SidebarArea',
  methods: {
    isActive(path) {
      return this.$route.path === path
    },

    async handleLogout() {
      try {
        await logout()
        this.$router.push('/login')
      } catch (error) {
        console.error('Logout error:', error)
      }
    },
  },
}
</script>

<style scoped>
.sidebar {
  width: 16rem; /* 64 */
}
.bg-primary-gradient {
  background: linear-gradient(135deg, #7f00ff, #3c8ce7);
  color: #fff;
}
.material-symbols-outlined {
  font-size: 20px !important;
}
</style>
