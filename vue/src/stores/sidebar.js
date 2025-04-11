import { defineStore } from "pinia";

export const useSidebarStore = defineStore("sidebar", {
  state: () => ({
    selected: "",
    isOpen: false,
  }),
  actions: {
    setSelected(label) {
      this.selected = label;
    },
    toggleSidebar() {
      this.isOpen = !this.isOpen;
    },
  },
});
