<script setup>
import { RouterLink, useRoute } from "vue-router";
import { ref, watch, onMounted } from "vue";

const route = useRoute();
const breadcrumbs = ref([]);

/**
 * Format route name or breadcrumb to Title Case
 */
const formatTitle = (text) => {
  if (!text) return "";
  return text
    .replace(/-/g, " ")
    .split(" ")
    .map((word) => word.charAt(0).toUpperCase() + word.slice(1))
    .join(" ");
};

/**
 * Generate breadcrumb list based on matched routes
 */
const generateBreadcrumbs = () => {
  const breadcrumbsArray = [];

  // Add Dashboard as the base breadcrumb if not already there
  if (route.path !== "/client/dashboard") {
    breadcrumbsArray.push({
      name: "Dashboard",
      path: "/client/dashboard",
    });
  }

  route.matched.forEach((matched) => {
    const metaName =
      matched.meta?.breadcrumbs || matched.meta?.title || matched.name || "";

    const fullPath = matched.path.includes(":") ? route.path : matched.path;

    // Avoid pushing duplicate dashboard path again
    if (fullPath !== "/client/dashboard") {
      breadcrumbsArray.push({
        name: metaName,
        path: fullPath,
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
  <nav class="breadcrumbs" aria-label="Breadcrumb">
    <ol class="flex items-center gap-2 p-2 text-sm md:text-base">
      <li
        v-for="(crumb, index) in breadcrumbs"
        :key="index"
        class="flex items-center"
      >
        <RouterLink
          v-if="index !== breadcrumbs.length - 1"
          :to="crumb.path"
          class="text-gray-800 hover:text-violet-700"
        >
          {{ formatTitle(crumb.name) }}
        </RouterLink>

        <span
          v-else
          class="text-gray-500 font-medium"
        >
          {{ formatTitle(crumb.name) }}
        </span>

        <span
          v-if="index !== breadcrumbs.length - 1"
          class="text-gray-300"
        >
          /
        </span>
      </li>
    </ol>
  </nav>
</template>
