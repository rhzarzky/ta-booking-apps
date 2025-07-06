<script setup>
import { computed, ref, onMounted, onBeforeUnmount } from "vue";
import { useRouter } from "vue-router";
import SidebarItem from "./SidebarItem.vue";
import { useAuthStore } from "@/stores/auth";
import { useSidebarStore } from "@/stores/sidebar";
import AppointlyIcon from "@/assets/icons/appointly.svg";
import {
  LayoutDashboard,
  ActivitySquare,
  UserCircle2,
  LogOut,
  Users,
  ChevronLeft,
  ChevronRight,
} from "lucide-vue-next";

const auth = useAuthStore();
const sidebar = useSidebarStore();
const router = useRouter();

// Responsive detection
const isMobile = ref(false);
const updateIsMobile = () => {
  isMobile.value = window.innerWidth < 768;
};

onMounted(() => {
  updateIsMobile();
  window.addEventListener("resize", updateIsMobile);
});

onBeforeUnmount(() => {
  window.removeEventListener("resize", updateIsMobile);
});

// Menu Items
const items = [
  { name: "Dashboard", icon: LayoutDashboard, route: "/client/dashboard" },
  { name: "Service", icon: Users, route: "/client/service" },
  { name: "History", icon: ActivitySquare, route: "/client/history" },
  { name: "Profile", icon: UserCircle2, route: "/client/profile" },
];

// Actions
const handleLogout = () => {
  sidebar.resetState();
  auth.handleLogout();
  router.push("/login");
};

const toggleSidebar = () => {
  sidebar.toggleSidebar();
};
</script>

<template>
  <!-- Overlay on mobile -->
  <div
    class="fixed inset-0 z-30 bg-black bg-opacity-50 md:hidden"
    v-if="sidebar.isSidebarOpen"
    @click="toggleSidebar"
  ></div>

  <!-- Sidebar -->
  <aside
    :class="[
      'z-40 bg-white border-r border-gray-200 h-full flex flex-col transition-all duration-300 shadow-lg',
      sidebar.isSidebarOpen ? 'w-64' : 'w-20',
      sidebar.isSidebarOpen || !isMobile ? 'block' : 'hidden',
      'fixed md:static'
    ]"
  >
    <!-- Header -->
    <div class="flex items-center p-4 border-b border-gray-200 relative">
      <div v-if="sidebar.isSidebarOpen" class="flex items-center">
        <img :src="AppointlyIcon" alt="Appointly Icon" class="h-10 w-13 mr-5" />
      </div>

      <!-- Toggle Sidebar (desktop only) -->
      <button
        @click="toggleSidebar"
        :class="[
          'absolute top-1/2 -translate-y-1/2 rounded-full p-1 bg-gray-100 text-gray-600 hover:bg-gray-200 shadow-md',
          sidebar.isSidebarOpen ? '-right-4' : 'right-[-1.5rem]',
          'hidden md:flex items-center justify-center'
        ]"
      >
        <ChevronLeft v-if="sidebar.isSidebarOpen" class="h-5 w-5" />
        <ChevronRight v-else class="h-5 w-5" />
      </button>

      <!-- Toggle Sidebar (mobile only) -->
      <button
        v-if="sidebar.isSidebarOpen || !isMobile"
        @click="toggleSidebar"
        class="ml-auto p-2 text-gray-500 hover:bg-gray-100 rounded-md md:hidden"
      >
        <svg
          xmlns="http://www.w3.org/2000/svg"
          class="h-6 w-6"
          fill="none"
          viewBox="0 0 24 24"
          stroke="currentColor"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M6 18L18 6M6 6l12 12"
          />
        </svg>
      </button>
    </div>

    <!-- Navigation -->
    <nav
      v-if="sidebar.isSidebarOpen || !isMobile"
      class="flex-1 px-4 py-3 space-y-2"
    >
      <SidebarItem
        v-for="item in items"
        :key="item.name"
        :icon="item.icon"
        :label="item.name"
        :to="item.route"
        :isOpen="sidebar.isSidebarOpen"
        class="text-gray-700"
        activeClass="bg-purple-600 text-white"
        hoverClass="hover:bg-purple-100 hover:text-purple-700"
      />
    </nav>

    <!-- Logout -->
    <div
      v-if="sidebar.isSidebarOpen || !isMobile"
      class="p-4 border-t border-gray-200"
    >
      <button
        @click="handleLogout"
        class="flex items-center w-full px-4 py-3 text-sm text-red-500 hover:bg-red-50 rounded-lg transition-colors duration-200"
      >
        <LogOut class="w-5 h-5 mr-3" />
        <span v-if="sidebar.isSidebarOpen" class="font-medium">Logout</span>
      </button>
    </div>
  </aside>
</template>
