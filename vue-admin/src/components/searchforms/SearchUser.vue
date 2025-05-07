<script setup>
const emit = defineEmits(["search"]);
const search = (e) => {
  emit("search", e.target.value);
};
</script>

<template>
    <div class="flex-1">
      <input
        @input="search"
        type="text"
        placeholder="Search User"
        class="w-full px-4 py-2 border-2 border-wildsand-200 rounded-lg text-codgray-900 font-medium cursor-pointer focus:outline-none focus:ring-2 focus:ring-offset-2 focus:text-cobalt-700 focus:ring-cobalt-600 hover:border-cobalt-500 transition-colors duration-200 text-sm md:text-base"
      />
    </div>
  </template>