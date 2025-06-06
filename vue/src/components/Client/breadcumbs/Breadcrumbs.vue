<script setup>
import { RouterLink, useRoute } from 'vue-router'
import { ref, watch, onMounted } from 'vue'

const route = useRoute()
const breadcrumbs = ref([])

/**
 * Format text to Title Case (e.g. 'edit-profile' → 'Edit Profile')
 */
const formatTitle = (text = '') =>
  text
    .replace(/-/g, ' ')
    .split(' ')
    .map(word => word.charAt(0).toUpperCase() + word.slice(1))
    .join(' ')

/**
 * Generate breadcrumbs in correct hierarchy
 */
const generateBreadcrumbs = () => {
  const crumbs = []

  // Filter matched routes to ignore base paths
  const matchedRoutes = route.matched.filter(m =>
    m.path !== '' &&
    m.path !== '/' &&
    m.path !== '/client'
  )

  matchedRoutes.forEach((matched) => {
    let name = matched.meta?.breadcrumbs || matched.meta?.title || matched.name
    if (!name) return

    name = formatTitle(name)

    const fullPath = matched.path.includes(':') ? route.fullPath : matched.path

    if (!crumbs.find(c => c.path === fullPath)) {
      crumbs.push({
        name,
        path: fullPath.startsWith('/client') ? fullPath : `/client${fullPath}`
      })
    }
  })

  // Tambahkan Dashboard di awal (jika bukan halaman dashboard)
  if (route.path !== '/client/dashboard') {
    crumbs.unshift({ name: 'Dashboard', path: '/client/dashboard' })
  }

  breadcrumbs.value = crumbs
}

onMounted(generateBreadcrumbs)
watch(() => route.path, generateBreadcrumbs)
</script>

<template>
  <nav class="breadcrumbs p-2" aria-label="Breadcrumb">
    <ol class="flex items-center gap-2 text-sm md:text-base">
      <li
        v-for="(crumb, index) in breadcrumbs"
        :key="index"
        class="flex items-center gap-1"
      >
        <RouterLink
          v-if="index !== breadcrumbs.length - 1"
          :to="crumb.path"
          class="text-gray-800 hover:text-violet-700 transition-colors"
        >
          {{ crumb.name }}
        </RouterLink>

        <span
          v-else
          class="text-gray-500 font-medium"
          aria-current="page"
        >
          {{ crumb.name }}
        </span>

        <span v-if="index !== breadcrumbs.length - 1" class="text-gray-300">
          /
        </span>
      </li>
    </ol>
  </nav>
</template>
