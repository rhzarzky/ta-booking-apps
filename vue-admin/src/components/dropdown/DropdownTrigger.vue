<script setup>
const props = defineProps({
  tag: {
    type: String,
    default: "button",
    validator: function (value) {
      return ["button", "a"].includes(value);
    },
  },
  isOpen: {
    type: Boolean,
    default: false,
  },
});
</script>

<template>
  <component
    :is="tag"
    class="px-4 py-2 text-gray-700 border rounded-md flex items-center gap-2"
  >
    <slot name="name-dropdown" />
    <svg
      :class="{ 'rotate-180 transition transform duration-300': isOpen }"
      xmlns="http://www.w3.org/2000/svg"
      class="size-4"
      fill="none"
      viewBox="0 0 24 24"
      stroke="currentColor"
    >
      <path
        stroke-linecap="round"
        stroke-linejoin="round"
        stroke-width="2"
        d="M19 9l-7 7-7-7"
      />
    </svg>
  </component>
</template>

<style scoped>
.rotate-180 {
  transform: rotate(180deg);
}
</style>