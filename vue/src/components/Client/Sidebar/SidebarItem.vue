<script setup>
import { useRoute, useRouter } from "vue-router";
import { computed, ref, watch } from "vue"; // Tambahkan 'watch' di sini
import { useSidebarStore } from "@/stores/sidebar";
import SidebarDropdown from "./SidebarDropdown.vue";
import { ChevronDown, ChevronUp } from "lucide-vue-next";

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
  children: { // Tambahkan prop children
    type: Array,
    default: () => [],
  },
});

const route = useRoute();
const router = useRouter();
const sidebar = useSidebarStore();

const isActive = computed(() => {
  if (props.to) {
    return route.path === props.to;
  }
  // If it has children, check if any child route is active
  if (props.children && props.children.length > 0) {
    return props.children.some(child => route.path.startsWith(child.route));
  }
  return false;
});

const isDropdownOpen = ref(isActive.value); // Buka dropdown jika salah satu anaknya aktif

// Watch route changes to open/close dropdown
watch(isActive, (newVal) => {
  if (newVal && props.children.length > 0) {
    isDropdownOpen.value = true;
  }
});


const handleClick = () => {
  if (props.children && props.children.length > 0) {
    isDropdownOpen.value = !isDropdownOpen.value;
  } else {
    sidebar.setSelected(props.label);
    sidebar.setPage(props.label);
    router.push(props.to);
  }
};
</script>

<template>
  <div>
    <button
      @click="handleClick"
      class="flex items-center gap-3 px-4 py-3 rounded-lg text-sm font-medium transition-colors w-full text-left"
      :class="[
        isActive && !props.children.length ? activeClass : `text-gray-700 ${hoverClass}`, // Apply active class only if no children or if its a direct link
        { 'bg-gray-100 text-purple-700': isActive && props.children.length } // Highlight parent if any child is active
      ]"
    >
      <component :is="icon" class="w-5 h-5" />
      <span v-if="isOpen">{{ label }}</span>
      <template v-if="isOpen && children.length > 0">
        <ChevronUp v-if="isDropdownOpen" class="w-4 h-4 ml-auto" />
        <ChevronDown v-else class="w-4 h-4 ml-auto" />
      </template>
    </button>

    <SidebarDropdown v-if="isOpen && children.length > 0 && isDropdownOpen" :items="children" />
  </div>
</template>