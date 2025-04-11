<script setup>
import { defineProps } from "vue";

const props = defineProps({ items: Array });
</script>

<template>
  <ul class="ml-6 mt-2 space-y-2">
    <li
      v-for="(child, index) in items"
      :key="index"
      class="p-2 pl-4 bg-gray-50 rounded-md hover:bg-gray-200"
    >
      <router-link :to="child.route">
        {{ child.label }}
      </router-link>
    </li>
  </ul>
</template>
