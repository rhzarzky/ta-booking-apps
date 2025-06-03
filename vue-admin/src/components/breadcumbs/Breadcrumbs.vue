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
  const pathArray = route.path.split("/").filter(Boolean);
  const breadcrumbsArray = [];

  // Dashboard
  breadcrumbsArray.push({
    name: "Dashboard",
    path: "/dashboard",
  });

  // Path before last (jika ada)
  if (pathArray.length > 2) {
    const pathBeforeLast = "/" + pathArray.slice(0, -2).join("/");
    if (pathBeforeLast !== "/") {
      breadcrumbsArray.push({
        name: formatTitle(pathArray[pathArray.length - 3]),
        path: pathBeforeLast,
      });
    }
  }

  // Current page (sebelum id)
  if (pathArray.length > 1) {
    const currentPagePath = "/" + pathArray.slice(0, -1).join("/");
    breadcrumbsArray.push({
      name: formatTitle(pathArray[pathArray.length - 2]),
      path: currentPagePath,
    });
  }

  // Name dari id (jika ada param id)
  const id = route.params.id;
  if (id) {
    // Ganti dengan cara ambil nama dari id sesuai kebutuhan Anda
    // Misal, ambil dari meta, props, atau API. Di sini contoh sederhana:
    breadcrumbsArray.push({
      name: `Detail ${id}`,
      path: route.path,
    });
  } else {
    // Jika tidak ada id, tampilkan halaman terakhir
    breadcrumbsArray.push({
      name: formatTitle(pathArray[pathArray.length - 1]),
      path: route.path,
    });
  }

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