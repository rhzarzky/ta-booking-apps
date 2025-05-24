<script setup>
import { computed } from "vue";
import { useRouter } from "vue-router";
import SidebarItem from "./SidebarItem.vue";
import { useAuthStore } from "@/stores/auth";
import { useSidebarStore } from "@/stores/sidebar";

import {
  LayoutDashboard,
  CalendarClock,
  ActivitySquare,
  UserCircle2,
  LogOut,
  Users
} from "lucide-vue-next";

// Stores
const auth = useAuthStore();
const sidebar = useSidebarStore();
const router = useRouter();

// Menu Items
const items = [
  { name: "Dashboard", icon: LayoutDashboard, route: "/client/dashboard" },
  { name: "Service", icon: Users, route: "/client/meeting" },
  { name: "Activity", icon: ActivitySquare, route: "/client/activity" },
  { name: "Profile", icon: UserCircle2, route: "/client/profile" },
];

// Actions
const handleLogout = () => {
  sidebar.resetState(); // Reset sidebar state on logout
  auth.handleLogout();
  router.push("/login");
};

const toggleSidebar = () => {
  sidebar.toggleSidebar();
};
</script>

<template>
  <!-- Overlay for mobile -->
  <div
    class="fixed inset-0 z-30 bg-black bg-opacity-50 md:hidden"
    v-if="sidebar.isSidebarOpen"
    @click="toggleSidebar"
  ></div>

  <aside
    :class="[
      'z-40 bg-white border-r border-gray-200 h-full flex flex-col transition-all duration-300',
      sidebar.isSidebarOpen ? 'w-64' : 'w-16',
      'fixed md:static'
    ]"
  >
    <!-- Top logo / toggle -->
    <div class="flex items-center justify-between p-4 border-b border-gray-200">
      <span v-if="sidebar.isSidebarOpen" class="font-bold text-lg">My App</span>
      <button
        @click="toggleSidebar"
        class="p-2 text-gray-500 hover:text-black md:hidden"
      >
        <svg
          v-if="sidebar.isSidebarOpen"
          xmlns="http://www.w3.org/2000/svg"
          class="h-6 w-6"
          fill="none"
          viewBox="0 0 24 24"
          stroke="currentColor"
        >
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
        </svg>
        <svg
          v-else
          xmlns="http://www.w3.org/2000/svg"
          class="h-6 w-6"
          fill="none"
          viewBox="0 0 24 24"
          stroke="currentColor"
        >
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h7" />
        </svg>
      </button>
    </div>

    <!-- Navigation -->
    <nav class="flex-1 p-2 space-y-1">
      <SidebarItem
        v-for="item in items"
        :key="item.name"
        :icon="item.icon"
        :label="item.name"
        :to="item.route"
        :isOpen="sidebar.isSidebarOpen"
      />
    </nav>

    <!-- Logout -->
    <div class="p-2 border-t border-gray-200">
      <button
        @click="handleLogout"
        class="flex items-center w-full px-3 py-2 text-sm text-red-500 hover:bg-red-50 rounded-md"
      >
        <LogOut class="w-5 h-5 mr-2" />
        <span v-if="sidebar.isSidebarOpen">Logout</span>
      </button>
    </div>
  </aside>
</template>
