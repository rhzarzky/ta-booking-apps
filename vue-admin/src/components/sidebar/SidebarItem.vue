<script setup>
import { computed } from "vue";
import { useSidebarStore } from "@/stores/sidebar";
import { useRoute, useRouter } from "vue-router";

import SidebarDropdown from "./SidebarDropdown.vue";

const sidebarStore = useSidebarStore();
const route = useRoute();
const router = useRouter();

const currentPage = route.name;

const props = defineProps({
  item: {
    type: Object,
    default: () => ({}),
  },
  index: {
    type: Number,
    default: 0,
  },
});

const isActive = computed(() => {
  if (props.item.route === route.path) {
    return true;
  }
  if (props.item.children) {
    return props.item.children.some((child) => child.route === route.path);
  }
  return false;
});

const handleItemClick = () => {
  if (props.item.children) {
    const pageName =
      sidebarStore.page === props.item.label ? "" : props.item.label;
    sidebarStore.setPage(pageName);

    if (props.item.children.some((child) => child.route === route.path)) {
      sidebarStore.setSelected(props.item.label);
    }
  } else {
    sidebarStore.setSelected(props.item.label);
    if (props.item.route) {
      router.push(props.item.route);
    }
  }
};
</script>

<template>
  <li>
    <div class="flex items-center gap-1">
      <hr
        v-if="isActive"
        class="absolute border-2 rounded-sm border-cobalt-600 left-0 h-6 w-1 bg-cobalt-600"
      />
      <router-link
        :to="item.route"
        class="group w-full relative flex items-center gap-2 rounded-md py-3 px-6 font-medium text-wildsand-50 duration-300 ease-in-out hover:bg-cobalt-900"
        @click.prevent="handleItemClick"
        :class="{
          'bg-gradient-to-r from-cobalt-700 to-cobalt-950': isActive
        }"
      >
        <span v-html="item.icon"></span>
        {{ item.label }}

        <svg
          v-if="item.children"
          class="absolute right-4 top-1/2 -translate-y-1/2 fill-current transition-transform"
          :class="{ 'rotate-180': isActive }"
          width="20"
          height="20"
          viewBox="0 0 20 20"
          fill="none"
          xmlns="http://www.w3.org/2000/svg"
        >
          <path
            fill-rule="evenodd"
            clip-rule="evenodd"
            d="M4.41107 6.9107C4.73651 6.58527 5.26414 6.58527 5.58958 6.9107L10.0003 11.3214L14.4111 6.91071C14.7365 6.58527 15.2641 6.58527 15.5896 6.91071C15.915 7.23614 15.915 7.76378 15.5896 8.08922L10.5896 13.0892C10.2641 13.4147 9.73651 13.4147 9.41107 13.0892L4.41107 8.08922C4.08563 7.76378 4.08563 7.23614 4.41107 6.9107Z"
            fill=""
          />
        </svg>
      </router-link>
    </div>

    <div
      class="translate transform overflow-hidden"
      v-show="isActive"
    >
      <SidebarDropdown
        v-if="item.children"
        :items="item.children"
        :currentPage="currentPage"
        :page="item.label"
      />
    </div>
  </li>
</template>