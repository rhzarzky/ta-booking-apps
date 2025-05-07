<script setup>
import { ref, watch, defineEmits } from "vue";

const props = defineProps({
  selectedStatuses: Array,
  selectedRoles: Array,
});

const emit = defineEmits(["updateStatus", "updateRole"]);
const localSelectedStatuses = ref([...props.selectedStatuses]);
const localSelectedRoles = ref([...props.selectedRoles]);
const isDropdownOpen = ref(false); // Menandakan apakah dropdown terbuka

watch(
  () => props.selectedStatuses,
  (newValue) => {
    localSelectedStatuses.value = [...newValue];
  }
);

watch(
  () => props.selectedRoles,
  (newValue) => {
    localSelectedRoles.value = [...newValue];
  }
);

const handleStatusChange = (value) => {
  if (value === "all") {
    localSelectedStatuses.value = localSelectedStatuses.value.includes("all")
      ? []
      : ["all"];
  } else {
    const index = localSelectedStatuses.value.indexOf(value);
    if (index === -1) {
      localSelectedStatuses.value.push(value);
    } else {
      localSelectedStatuses.value.splice(index, 1);
    }

    if (localSelectedStatuses.value.includes("all")) {
      localSelectedStatuses.value = ["all"];
    }
  }
  emit("updateStatus", localSelectedStatuses.value);
};

const handleRoleChange = (value) => {
  const index = localSelectedRoles.value.indexOf(value);
  if (index === -1) {
    localSelectedRoles.value.push(value);
  } else {
    localSelectedRoles.value.splice(index, 1);
  }
  emit("updateRole", localSelectedRoles.value);
};

const toggleDropdown = () => {
  isDropdownOpen.value = !isDropdownOpen.value;
};

const statusOptions = [
  { label: "All", value: "all" },
  { label: "Active", value: "active" },
  { label: "Inactive", value: "inactive" },
];

const roleOptions = [
  { label: "Developer", value: "developer" },
  { label: "User", value: "user" },
];
</script>

<template>
  <div class="relative inline-block text-left">
    <button
      @click="toggleDropdown"
      class="flex gap-3 border-2 border-cobalt-800 text-cobalt-800 px-4 py-2 rounded-xl"
    >
      Filters
      <svg
        xmlns="http://www.w3.org/2000/svg"
        width="20px"
        height="20px"
        viewBox="0 0 24 24"
        class="size-4 md:size-5"
      >
        <path
          fill="none"
          stroke="currentColor"
          stroke-width="1.5"
          d="M19 3H5c-1.414 0-2.121 0-2.56.412S2 4.488 2 5.815v.69c0 1.037 0 1.556.26 1.986s.733.698 1.682 1.232l2.913 1.64c.636.358.955.537 1.183.735c.474.411.766.895.898 1.49c.064.284.064.618.064 1.285v2.67c0 .909 0 1.364.252 1.718c.252.355.7.53 1.594.88c1.879.734 2.818 1.101 3.486.683S15 19.452 15 17.542v-2.67c0-.666 0-1 .064-1.285a2.68 2.68 0 0 1 .899-1.49c.227-.197.546-.376 1.182-.735l2.913-1.64c.948-.533 1.423-.8 1.682-1.23c.26-.43.26-.95.26-1.988v-.69c0-1.326 0-1.99-.44-2.402C21.122 3 20.415 3 19 3Z"
        />
      </svg>
    </button>
    <div
      v-if="isDropdownOpen"
      class="absolute bg-white border border-wildsand-200 rounded-xl shadow-lg mt-4 p-4 z-10"
    >
      <h4 class="font-bold mb-2 text-sm md:text-base text-codgray-950">
        Filter by Status
      </h4>
      <div class="flex flex-row gap-2 mb-4">
        <label class="flex items-center font-medium text-sm text-codgray-600">
          <input
            type="checkbox"
            value="all"
            :checked="localSelectedStatuses.includes('all')"
            @change="handleStatusChange('all')"
            class="mr-1 size-4"
          />
          All
        </label>
        <label class="flex items-center font-medium text-sm text-codgray-600">
          <input
            type="checkbox"
            value="active"
            :checked="localSelectedStatuses.includes('active')"
            @change="handleStatusChange('active')"
            class="mr-1 size-4"
          />
          Active
        </label>
        <label class="flex items-center text-sm font-medium text-codgray-600">
          <input
            type="checkbox"
            value="inactive"
            :checked="localSelectedStatuses.includes('inactive')"
            @change="handleStatusChange('inactive')"
            class="mr-1 size-4"
          />
          Inactive
        </label>
      </div>

      <h4 class="font-bold mb-2 text-codgray-950">Filter by Role</h4>
      <div>
        <div
          v-for="option in roleOptions"
          :key="option.value"
          class="flex items-centerflex-row mb-2"
        >
          <input
            type="checkbox"
            :value="option.value"
            :checked="localSelectedRoles.includes(option.value)"
            @change="handleRoleChange(option.value)"
            class="mr-2 leading-tight"
          />
          <label class="text-gray-700">{{ option.label }}</label>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
/* Beberapa gaya untuk dropdown jika diperlukan */
</style>