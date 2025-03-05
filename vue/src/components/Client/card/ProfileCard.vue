<!-- components/ProfileCard.vue
<template>
  <div class="bg-white p-6 rounded-lg shadow">
    <div class="flex items-center mb-6">
      <div class="w-16 h-16 bg-gray-200 rounded-full flex items-center justify-center mr-4">
        <span class="text-2xl font-bold">AJ</span>
      </div>
      <div>
        <h2 class="text-xl font-bold">{{ name }}</h2>
        <p class="text-gray-600">{{ email }}</p>
      </div>
    </div>
    <button class="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600">
      Edit
    </button>
  </div>
</template>

<script>
export default {
  name: 'ProfileCard',
  props: {
    name: {
      type: String,
      required: true,
    },
    email: {
      type: String,
      required: true,
    },
  },
};
</script>

<style scoped>
/* Tambahkan gaya khusus jika diperlukan */
</style> -->