// stores/sidebar.js
import { defineStore } from "pinia";
import { ref } from "vue";
import { useStorage } from "@vueuse/core";

export const useSidebarStore = defineStore("sidebar", () => {
  // Persistent State
  const isSidebarOpen = useStorage("sidebar-open", true);
  const selected = useStorage("sidebar-selected", "");
  const page = useStorage("sidebar-page", "Dashboard");

  // Actions
  const toggleSidebar = () => {
    isSidebarOpen.value = !isSidebarOpen.value;
  };

  const setSelected = (value) => {
    selected.value = value;
  };

  const setPage = (value) => {
    page.value = value;
  };

  const resetState = () => {
    isSidebarOpen.value = true;
    selected.value = "";
    page.value = "Dashboard";
  };

  // Getters
  const isItemSelected = (itemName) => selected.value === itemName;
  const isPageActive = (pageName) => page.value === pageName;

  return {
    isSidebarOpen,
    selected,
    page,
    toggleSidebar,
    setSelected,
    setPage,
    resetState,
    isItemSelected,
    isPageActive,
  };
});
