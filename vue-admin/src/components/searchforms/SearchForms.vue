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
      placeholder="Search presma app"
      class="w-full px-4 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-cobalt-700"
    />
  </div>
</template>