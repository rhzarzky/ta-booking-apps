<script setup>
import { defineProps } from "vue";
import { useRoute } from "vue-router"; // Import useRoute untuk cek aktif link

const props = defineProps({ items: Array });
const route = useRoute(); // Inisialisasi useRoute

const isChildActive = (path) => {
  return route.path === path;
};
</script>

<template>
  <ul class="ml-6 mt-2 space-y-2">
    <li
      v-for="(child, index) in items"
      :key="index"
      class="p-2 pl-4 rounded-md transition-colors"
      :class="{
        'bg-purple-100 text-purple-700 font-semibold': isChildActive(child.route), // Active style
        'hover:bg-gray-200': !isChildActive(child.route) // Hover style for inactive
      }"
    >
      <router-link :to="child.route" class="block w-full h-full">
        {{ child.label }}
      </router-link>
    </li>
  </ul>
</template>