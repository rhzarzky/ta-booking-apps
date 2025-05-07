<script setup>
import { useSidebarStore } from "@/stores/sidebar";

import DropdownUser from "../dropdown/DropdownUser.vue";
import Breadcrumbs from "../breadcumbs/Breadcrumbs.vue";

const { toggleSidebar } = useSidebarStore();
</script>

<template>
  <header
    class="sticky top-0 z-40 w-full bg-white "
  >
    <div
      class="flex flex-grow items-center justify-between gap-3 px-4 py-2  border-b border-wildsand-200" 
    >
      <div class="flex items-center w-full">
        <!-- Mobile Sidebar Toggle -->
        <div class="flex items-center mr-4 lg:hidden">
          <button
            class="flex flex-col justify-center items-center w-10 h-10 cursor-pointer focus:outline-none group"
            @click="toggleSidebar"
            aria-label="Toggle Sidebar"
          >
            <span
              class="block w-6 h-0.5 bg-gray-600 transition-all duration-300 group-[.active]:rotate-45 group-[.active]:translate-y-1.5"
            ></span>
            <span
              class="block w-6 h-0.5 bg-gray-600 my-1 transition-all duration-300 group-[.active]:opacity-0"
            ></span>
            <span
              class="block w-6 h-0.5 bg-gray-600 transition-all duration-300 group-[.active]:-rotate-45 group-[.active]:-translate-y-1.5"
            ></span>
          </button>
        </div>
        
        <!-- Breadcrumbs -->
        <div class="flex-grow overflow-hidden">
          <Breadcrumbs />
        </div>

        <!-- User Dropdown -->
        <div class="flex items-center mr-4">
          <DropdownUser />
        </div>
      </div>
    </div>
  </header>
</template>

<style scoped>
@media (max-width: 640px) {
  .hamburger-btn span {
    width: 1.25rem; /* equivalent to w-5 */
  }
}
</style>