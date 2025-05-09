import { useStorage } from "@vueuse/core";
import { defineStore } from "pinia";
import { ref } from "vue";

export const useSidebarStore = defineStore("sidebar", () => {
  // State
  const isSidebarOpen = ref(false);
  const selected = useStorage("selected", ref(" "));
  const page = useStorage("page", ref("Dashboard"));

  // Actions
  function toggleSidebar() {
    isSidebarOpen.value = !isSidebarOpen.value;
  }

  function setSelected(value) {
    selected.value = value;
  }

  function setPage(value) {
    page.value = value;
  }

  function resetState() {
    isSidebarOpen.value = false;
    selected.value = " ";
    page.value = "Dashboard";
  }

  // Getters
  const isPageActive = (pageName) => page.value === pageName;
  const isItemSelected = (itemName) => selected.value === itemName;

  return {
    // State
    isSidebarOpen,
    selected,
    page,

    // Actions
    toggleSidebar,
    setSelected,
    setPage,
    resetState,

    // Getters
    isPageActive,
    isItemSelected,
  };
});
