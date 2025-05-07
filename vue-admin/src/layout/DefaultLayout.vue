<script setup>
import SidebarArea from "@/components/sidebar/SidebarArea.vue";
import HeaderArea from "@/components/header/HeaderArea.vue";
</script>

<template>
  <div class="flex h-screen overflow-hidden">
    <!-- sidebar start -->
    <SidebarArea />

    <!-- content area start -->
    <div
      class="relative flex flex-1 flex-col overflow-y-auto overflow-x-hidden"
    >
      <!-- header start -->
      <HeaderArea />

      <!-- main content start -->
      <main>
        <div class="bg-whiteBgPrimary-100 max-w-screen-7xl p-4 md:p-6 overflow-hidden">
          <slot></slot>
        </div>
      </main>
      <!-- main content end -->
    </div>
    <!-- content area end -->
  </div>
</template>