<script setup>
inheritAttrs: false;
</script>
<template>
  <li class="px-4 py-2  border-b-[1px] border-wildsand-300 rounded-b-lg text-codgray-800 font-Poppins font-medium hover:bg-wildsand-100">
    <a v-bind="$attrs">
        <slot />
    </a>
  </li>
</template>