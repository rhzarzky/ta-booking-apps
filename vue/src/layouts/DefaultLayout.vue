<script setup>
import SidebarArea from "@/components/Client/Sidebar/SidebarArea.vue";
import HeaderArea from "@/components/Client/header/HeaderArea.vue";
</script>

<template>
  <div class="flex h-screen overflow-hidden">
    <!-- sidebar start -->
    <SidebarArea />

    <!-- content area start -->
    <div class="relative flex flex-1 flex-col overflow-y-auto overflow-x-hidden bg-gray-100">
      <!-- header start -->
      <HeaderArea />

      <!-- main content start -->
      <main>
        <div class="max-w-screen-7xl p-4 md:p-6">
          <router-view />
        </div>
      </main>
      <!-- main content end -->
    </div>
    <!-- content area end -->
  </div>
</template>
