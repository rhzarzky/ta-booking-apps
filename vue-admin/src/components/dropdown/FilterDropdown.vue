<script setup>
import { ref, watch } from "vue";

const props = defineProps({
  statusFilter: {
    type: Array,
    default: () => [],
  },
  timeFilter: {
    type: String,
    default: "all",
  },
});

const emit = defineEmits(["updateStatus", "updateTime"]);

const show = ref(false);
const selectedStatuses = ref(props.statusFilter);
const selectedTimeRange = ref(props.timeFilter);

watch(
  () => props.statusFilter,
  (newValue) => {
    selectedStatuses.value = newValue;
  },
  { deep: true }
);

watch(
  () => props.timeFilter,
  (newValue) => {
    selectedTimeRange.value = newValue;
  }
);

const handleStatusChange = () => {
  emit("updateStatus", selectedStatuses.value);
};

const handleTimeChange = (value) => {
  selectedTimeRange.value = value;
  emit("updateTime", value);
};

const statusOptions = [
  { label: "Error", value: "error" },
  { label: "Unresolved", value: "unresolved" },
  { label: "Resolved", value: "resolved" },
  { label: "Ignored", value: "ignored" },
];

const timeOptions = [
  { label: "Last 24 hours", value: "24h" },
  { label: "Last 7 days", value: "7d" },
  { label: "Last 30 days", value: "30d" },
  { label: "All time", value: "all" },
];
</script>

<template>
  <div class="relative flex items-center w-full">
    <button
      @click="show = !show"
      class="w-full border rounded-md flex gap-2 items-center justify-center py-2 px-4 text-base font-medium text-codgray-600"
    >
      Filters
      <svg
        :class="{ 'rotate-180 transition transform duration-300': show }"
        xmlns="http://www.w3.org/2000/svg"
        class="size-4"
        fill="none"
        viewBox="0 0 24 24"
        stroke="currentColor"
      >
        <path
          stroke-linecap="round"
          stroke-linejoin="round"
          stroke-width="2"
          d="M19 9l-7 7-7-7"
        />
      </svg>
    </button>

    <div
      v-if="show"
      class="absolute top-12 right-0 z-10 w-64 p-4 bg-white rounded-xl shadow"
    >
      <div class="mb-4">
        <h6 class="mb-3 text-sm font-medium text-codgray-600">Status</h6>
        <ul class="space-y-2 text-sm">
          <li v-for="status in statusOptions" :key="status.value">
            <div class="flex items-center">
              <input
                type="checkbox"
                :id="status.value"
                v-model="selectedStatuses"
                :value="status.value"
                @change="handleStatusChange"
                class="w-4 h-4 bg-wildsand-300"
              />
              <label
                :for="status.value"
                class="ml-2 text-sm font-medium text-codgray-600"
              >
                {{ status.label }}
              </label>
            </div>
          </li>
        </ul>
      </div>

      <div>
        <h6 class="mb-3 text-sm font-medium text-codgray-600">Time Range</h6>
        <ul class="space-y-2 text-sm">
          <li v-for="time in timeOptions" :key="time.value">
            <div class="flex items-center">
              <input
                type="radio"
                :id="time.value"
                v-model="selectedTimeRange"
                :value="time.value"
                @change="handleTimeChange(time.value)"
                class="w-4 h-4 bg-wildsand-300"
              />
              <label
                :for="time.value"
                class="ml-2 text-sm font-medium text-codgray-600"
              >
                {{ time.label }}
              </label>
            </div>
          </li>
        </ul>
      </div>
    </div>
  </div>
</template>