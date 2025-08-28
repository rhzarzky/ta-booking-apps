<script setup>
const props = defineProps({
  message: {
    type: String,
    required: true,
  },
  type: {
    type: String,
    default: "success",
  },
  isVisible: {
    type: Boolean,
    required: true,
  },
});

const emit = defineEmits(["close"]);

if (props.isVisible) {
  setTimeout(() => {
    emit("close");
  }, 3000);
}
</script>

<template>
  <Transition
    enter-active-class="transform ease-out duration-300 transition"
    enter-from-class="translate-y-2 opacity-0 sm:translate-y-0 sm:translate-x-2"
    enter-to-class="translate-y-0 opacity-100 sm:translate-x-0"
    leave-active-class="transition ease-in duration-100"
    leave-from-class="opacity-100"
    leave-to-class="opacity-0"
  >
    <div v-if="isVisible" class="fixed top-4 right-4 z-50">
      <div
        class="p-4 border-l-4 rounded-r-xl"
        :class="{
          'border-green-500 bg-green-50': type === 'success',
          'border-red-500 bg-red-50': type === 'error',
        }"
      >
        <div class="flex">
          <div class="flex-shrink-0">
            <svg
              v-if="type === 'success'"
              class="w-5 h-5 text-green-400"
              xmlns="http://www.w3.org/2000/svg"
              viewBox="0 0 20 20"
              fill="currentColor"
            >
              <path
                fill-rule="evenodd"
                d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
                clip-rule="evenodd"
              />
            </svg>
            <svg
              v-else
              class="w-5 h-5 text-red-400"
              xmlns="http://www.w3.org/2000/svg"
              viewBox="0 0 20 20"
              fill="currentColor"
            >
              <path
                fill-rule="evenodd"
                d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z"
                clip-rule="evenodd"
              />
            </svg>
          </div>
          <div class="ml-3">
            <div
              class="text-sm"
              :class="{
                'text-green-600': type === 'success',
                'text-red-600': type === 'error',
              }"
            >
              <p>{{ message }}</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </Transition>
</template>