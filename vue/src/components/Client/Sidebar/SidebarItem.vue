<script setup>
import { useRoute, useRouter } from "vue-router";
import { computed } from "vue";
import { useSidebarStore } from "@/stores/sidebar";

const props = defineProps({
  icon: [Object, Function],
  label: String,
  to: String,
  isOpen: Boolean,
  activeClass: {
    type: String,
    default: "bg-purple-600 text-white",
  },
  hoverClass: {
    type: String,
    default: "hover:bg-purple-100 hover:text-purple-700",
  },
});

const route = useRoute();
const router = useRouter();
const sidebar = useSidebarStore();

const isActive = computed(() => route.path === props.to);

const handleClick = () => {
  sidebar.setSelected(props.label);
  sidebar.setPage(props.label);
  router.push(props.to);
};
</script>

<template>
  <button
    @click="handleClick"
    class="flex items-center gap-3 px-4 py-3 rounded-lg text-sm font-medium transition-colors w-full text-left"
    :class="[
      isActive ? activeClass : `text-gray-700 ${hoverClass}`
    ]"
  >
    <component :is="icon" class="w-5 h-5" />
    <span v-if="isOpen">{{ label }}</span>
  </button>
</template>
