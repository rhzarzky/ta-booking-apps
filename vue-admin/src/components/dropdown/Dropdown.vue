<script setup>
import { ref, computed } from "vue";
import { onClickOutside } from "@vueuse/core";

const isOpen = ref(false);
const dropdownRef = ref(null);

onClickOutside(dropdownRef, e => {
    isOpen.value = false
})

const toggle = () => {
  isOpen.value = !isOpen.value;
};

const toggleClass = computed(() => (isOpen.value ? "show" : ""));
</script>

<template>
  <div class="relative" ref="dropdownRef">
    <slot name="trigger" :toggleClass="toggleClass" :toggle="toggle"  :isOpen="isOpen" />

    <ul
      class="absolute w-full transform rounded-b-lg mt-1 cursor-pointer bg-white drop-shadow-md"
      :class="toggleClass"
      v-if="isOpen"
    >
      <slot name="menu" :toggle="toggle" />
    </ul>
  </div>
</template>
