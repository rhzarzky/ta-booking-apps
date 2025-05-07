<script setup>
import { RouterLink, useRoute } from "vue-router";
import { ref, watch, onMounted } from "vue";

const route = useRoute();
const breadcrumbs = ref([]);

const formatTitle = (text) => {
  if (!text) return "";
  return text
    .replace(/-/g, " ") 
    .split(" ") 
    .map((word) => word.charAt(0).toUpperCase() + word.slice(1))
    .join(" "); 
};

const generateBreadcrumbs = () => {
  const pathArray = route.path.split("/");
  const breadcrumbsArray = [];

  breadcrumbsArray.push({
    name: "Dashboard",
    path: "/Dashboard",
  });

  let currentPath = "";
  pathArray.forEach((path, index) => {
    if (path) {
      currentPath += `/${path}`;

      const matchedRoute = route.matched[index];
      const name =
        matchedRoute?.meta?.breadcrumbs || matchedRoute?.meta?.title || path;

      breadcrumbsArray.push({
        name: name,
        path: currentPath,
      });
    }
  });

  breadcrumbs.value = breadcrumbsArray;
};

onMounted(() => {
  generateBreadcrumbs();
});

watch(
  () => route.path,
  () => {
    generateBreadcrumbs();
  }
);
</script>
<template>
  <nav class="breadcrumbs" aria-label="breadcrumb">
    <ol class="flex items-center p-2">
      <li
        v-for="(crumb, index) in breadcrumbs"
        :key="index"
        class="flex items-center"
      >
        <router-link
          v-if="index !== breadcrumbs.length - 1"
          :to="crumb.path"
          class="text-codgray-950 hover:text-violet-950 text-sm md:text-base"
        >
          <span>{{ formatTitle(crumb.name) }}</span>
        </router-link>
        <span v-else class="text-codgray-600 font-medium text-sm md:text-base">
          {{ formatTitle(crumb.name) }}
        </span>
        <span
          v-if="index !== breadcrumbs.length - 1"
          class="mx-2 text-wildsand-400"
        >
          /
        </span>
      </li>
    </ol>
  </nav>
</template>