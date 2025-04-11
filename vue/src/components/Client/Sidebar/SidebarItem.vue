<script setup>
import { ref, computed, defineProps, defineEmits } from "vue";
import { useSidebarStore } from "@/stores/sidebar";
import SidebarDropdown from "./SidebarDropdown.vue";

const props = defineProps({ item: Object, selected: String });
const emit = defineEmits(["update:selected"]);

const sidebarStore = useSidebarStore();
const isActive = computed(() => props.selected === props.item.label);
const isOpen = ref(false);

const handleClick = () => {
  if (props.item.children) {
    isOpen.value = !isOpen.value;
  } else {
    emit("update:selected", props.item.label);
  }
};
</script>

<template>
  <li>
    <div
      class="flex items-center gap-2 p-3 cursor-pointer rounded-md hover:bg-gray-100"
      :class="{ 'bg-gray-200': isActive }"
      @click="handleClick"
    >
      <span>{{ item.icon }}</span>
      <span v-if="sidebarStore.isOpen">{{ item.label }}</span>
      <span v-if="item.children">▼</span>
    </div>

    <SidebarDropdown v-if="item.children" :items="item.children" v-show="isOpen" />
  </li>
</template>
