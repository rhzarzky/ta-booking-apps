<script setup>
import { useRoute, useRouter } from "vue-router";
import { computed } from "vue";
import { useSidebarStore } from "@/stores/sidebar";

const props = defineProps({
  icon: [Object, Function],
  label: String,
  to: String,
  isOpen: Boolean,
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
    class="flex items-center gap-3 px-3 py-2 rounded-md text-sm font-medium transition-colors w-full text-left"
    :class="[
      isActive ? 'bg-blue-100 text-blue-600' : 'text-gray-600 hover:bg-gray-100 hover:text-black'
    ]"
  >
    <component :is="icon" class="w-5 h-5" />
    <span v-if="isOpen">{{ label }}</span>
  </button>
</template>
