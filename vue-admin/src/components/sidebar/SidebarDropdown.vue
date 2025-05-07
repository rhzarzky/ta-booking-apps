<script setup>
import { useSidebarStore } from "@/stores/sidebar";
import { ref, toRef } from "vue";

const sidebarStore = useSidebarStore();

const props = defineProps(["items", "page"]);
const items = toRef(props, "items");

const handleItemClick = (index) => {
  const pageName =
    sidebarStore.selected === items.value[index].label
      ? ""
      : items.value[index].label;
  sidebarStore.selected = pageName;
};
</script>

<template>
  <ul class="mt-4 mb-5 flex flex-col gap-2 pl-6">
    <li v-for="(childItem, index) in items" :key="index">
      <router-link
        :to="childItem.route"
        @click="handleItemClick(index)"
        class="group relative flex items-center gap-2 rounded-md text-sm font-medium text-cobalt-50 duration-300 ease-in-out"
        :class="{ '!text-valentino-100': childItem.label === sidebarStore.selected }"
      >
        {{ childItem.label }}
      </router-link>
    </li>
  </ul>
</template>
