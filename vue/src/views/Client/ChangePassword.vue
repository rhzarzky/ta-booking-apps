<template>
  <div class="p-6 max-w-2xl mx-auto relative">
    <div class="fixed top-4 right-4 z-50 space-y-3">
      <div
        v-for="notification in notifications"
        :key="notification.id"
        :class="[
          'p-4 rounded-lg shadow-md text-white flex items-center justify-between transition-all duration-300 transform',
          {
            'bg-green-500': notification.type === 'success',
            'bg-red-500': notification.type === 'error',
            'bg-yellow-500': notification.type === 'warning',
          }
        ]"
      >
        <span>{{ notification.message }}</span>
        <button @click="removeNotification(notification.id)" class="ml-4 text-white hover:text-gray-100 focus:outline-none">
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
        </button>
      </div>
    </div>

    <div class="bg-white shadow-lg rounded-xl p-6 sm:p-10">
      <h2 class="text-2xl font-bold mb-6 text-gray-800 border-b pb-4">Change Password</h2>

      <form @submit.prevent="handleSubmit" class="space-y-5">

        <div>
          <label for="current_password" class="block text-sm font-medium text-gray-700 mb-1">Current Password</label>
          <div class="relative">
            <input
              id="current_password"
              :type="showCurrent ? 'text' : 'password'"
              v-model="form.current_password"
              class="w-full px-4 py-2 border rounded-md focus:outline-none focus:ring-2 transition duration-150 ease-in-out"
              :class="errors.current_password ? 'border-red-500 focus:ring-red-300' : 'border-gray-300 focus:ring-indigo-300'"
            />
            <button type="button" @click="showCurrent = !showCurrent" class="absolute right-3 top-1/2 -translate-y-1/2 text-gray-500 hover:text-gray-700 p-1 rounded-full focus:outline-none focus:ring-2 focus:ring-indigo-300">
              <svg v-if="showCurrent" class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.875 18.825A10.05 1005 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.602-5.462a4.99 4.99 0 018.665 6.002m-4.223 2.477c.334.303.58.652.753 1.037.669 1.547-.488 3.195-2.036 3.864-.813.353-1.637.56-2.527.56C8.895 19 6.84 17.514 6 15.344" /></svg>
              <svg v-else class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" /><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" /></svg>
            </button>
          </div>
          <p v-if="errors.current_password" class="text-sm text-red-500 mt-1">
            {{ errors.current_password }}
          </p>
        </div>

        <div>
          <label for="password" class="block text-sm font-medium text-gray-700 mb-1">New Password</label>
          <div class="relative flex items-center">
            <input
              id="password"
              :type="showNew ? 'text' : 'password'"
              v-model="form.password"
              @input="validatePasswordCriteria"
              class="w-full px-4 py-2 border rounded-md focus:outline-none focus:ring-2 transition duration-150 ease-in-out pr-12"
              :class="localErrors.password ? 'border-red-500 focus:ring-red-300' : 'border-gray-300 focus:ring-indigo-300'"
            />
            <button type="button" @click="showNew = !showNew" class="absolute right-10 top-1/2 -translate-y-1/2 text-gray-500 hover:text-gray-700 p-1 rounded-full focus:outline-none focus:ring-2 focus:ring-indigo-300">
              <svg v-if="showNew" class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.875 18.825A10.05 1005 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.602-5.462a4.99 4.99 0 018.665 6.002m-4.223 2.477c.334.303.58.652.753 1.037.669 1.547-.488 3.195-2.036 3.864-.813.353-1.637.56-2.527.56C8.895 19 6.84 17.514 6 15.344" /></svg>
              <svg v-else class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" /><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" /></svg>
            </button>
            <button type="button" @click="generatePassword" class="absolute right-2 top-1/2 -translate-y-1/2 text-gray-500 hover:text-gray-700 p-1 rounded-full focus:outline-none focus:ring-2 focus:ring-indigo-300" title="Generate Strong Password">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 7a2 2 0 012 2v5l-2 2h-4L9 14V9a2 2 0 012-2h4zm-5 7h4m-4-7V7m2 0V5a2 2 0 00-2-2H7a2 2 0 00-2 2v2m8 0V5a2 2 0 012-2h4a2 2 0 012 2v2m-3 7h-2m-2 0h-2m-2 0h-2m-2 0h-2m-2 0h-2M15 12H9m6 0h4m-4 0h-4m-4 0h-4m-4 0h-4"/></svg>
            </button>
          </div>

          <ul v-if="formSubmitted && !allPasswordCriteriaMet" class="text-sm text-gray-600 mt-2 space-y-1">
            <li :class="{ 'text-green-600': passwordLengthValid, 'text-red-500': !passwordLengthValid }">
              <span v-if="passwordLengthValid">&#10003;</span>
              <span v-else>&#10007;</span>
              Minimum 8 characters
            </li>
            <li :class="{ 'text-green-600': passwordHasUppercase, 'text-red-500': !passwordHasUppercase }">
              <span v-if="passwordHasUppercase">&#10003;</span>
              <span v-else>&#10007;</span>
              At least one uppercase letter (A-Z)
            </li>
            <li :class="{ 'text-green-600': passwordHasLowercase, 'text-red-500': !passwordHasLowercase }">
              <span v-if="passwordHasLowercase">&#10003;</span>
              <span v-else>&#10007;</span>
              At least one lowercase letter (a-z)
            </li>
            <li :class="{ 'text-green-600': passwordHasNumber, 'text-red-500': !passwordHasNumber }">
              <span v-if="passwordHasNumber">&#10003;</span>
              <span v-else>&#10007;</span>
              At least one number (0-9)
            </li>
            <li :class="{ 'text-green-600': passwordHasSpecialChar, 'text-red-500': !passwordHasSpecialChar }">
              <span v-if="passwordHasSpecialChar">&#10003;</span>
              <span v-else>&#10007;</span>
              At least one special character (@$!%*#?&^)
            </li>
          </ul>
        </div>

        <div>
          <label for="password_confirmation" class="block text-sm font-medium text-gray-700 mb-1">Confirm New Password</label>
          <div class="relative">
            <input
              id="password_confirmation"
              :type="showConfirm ? 'text' : 'password'"
              v-model="form.password_confirmation"
              class="w-full px-4 py-2 border rounded-md focus:outline-none focus:ring-2 transition duration-150 ease-in-out"
              :class="errors.password_confirmation ? 'border-red-500 focus:ring-red-300' : 'border-gray-300 focus:ring-indigo-300'"
            />
            <button type="button" @click="showConfirm = !showConfirm" class="absolute right-3 top-1/2 -translate-y-1/2 text-gray-500 hover:text-gray-700 p-1 rounded-full focus:outline-none focus:ring-2 focus:ring-indigo-300">
              <svg v-if="showConfirm" class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.875 18.825A10.05 1005 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.602-5.462a4.99 4.99 0 018.665 6.002m-4.223 2.477c.334.303.58.652.753 1.037.669 1.547-.488 3.195-2.036 3.864-.813.353-1.637.56-2.527.56C8.895 19 6.84 17.514 6 15.344" /></svg>
              <svg v-else class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" /><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" /></svg>
            </button>
          </div>
          <p v-if="errors.password_confirmation" class="text-sm text-red-500 mt-1">
            {{ errors.password_confirmation }}
          </p>
        </div>

        <div class="flex flex-col sm:flex-row justify-end gap-4 pt-4">
          <button
            type="button"
            @click="router.push('/client/profile')"
            class="w-full sm:w-auto px-6 py-2 rounded-md border border-gray-300 text-gray-700 hover:bg-gray-100 transition duration-150 ease-in-out focus:outline-none focus:ring-2 focus:ring-gray-400"
          >
            Cancel
          </button>
          <button
            type="submit"
            :disabled="isSubmitting"
            class="w-full sm:w-auto px-6 py-2 rounded-md bg-indigo-600 text-white font-medium hover:bg-indigo-700 transition duration-150 ease-in-out focus:outline-none focus:ring-2 focus:ring-indigo-500 flex items-center justify-center gap-2"
          >
            <svg v-if="isSubmitting" class="animate-spin h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
              <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
              <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
            </svg>
            {{ isSubmitting ? 'Updating...' : 'Update Password' }}
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

// --- Notification System Setup ---
const notifications = ref([]);
let notificationId = 0;

const showNotification = (type, message) => {
  const id = notificationId++;
  notifications.value.push({ id, type, message });
  setTimeout(() => {
    removeNotification(id);
  }, 5000); // Notifications disappear after 5 seconds
};

const removeNotification = (id) => {
  notifications.value = notifications.value.filter(n => n.id !== id);
};
// --- End Notification System Setup ---

const router = useRouter()
const auth = useAuthStore()

const form = ref({
  current_password: '',
  password: '',
  password_confirmation: '',
})

const showCurrent = ref(false)
const showNew = ref(false)
const showConfirm = ref(false)
const isSubmitting = ref(false)
const formSubmitted = ref(false) // New ref to track form submission for criteria display

const errors = ref({
  current_password: '',
  password: '',
  password_confirmation: ''
})

// New ref for local password validation errors (to avoid conflicting with API errors)
const localErrors = ref({
  password: ''
})

// Password criteria checks (new refs)
const passwordLengthValid = ref(false)
const passwordHasUppercase = ref(false)
const passwordHasLowercase = ref(false)
const passwordHasNumber = ref(false)
const passwordHasSpecialChar = ref(false)

// Computed property to check if all password criteria are met
const allPasswordCriteriaMet = computed(() => {
  return (
    passwordLengthValid.value &&
    passwordHasUppercase.value &&
    passwordHasLowercase.value &&
    passwordHasNumber.value &&
    passwordHasSpecialChar.value
  )
})

// Function to validate password criteria
const validatePasswordCriteria = () => {
  const password = form.value.password;
  passwordLengthValid.value = password.length >= 8;
  passwordHasUppercase.value = /[A-Z]/.test(password);
  passwordHasLowercase.value = /[a-z]/.test(password);
  passwordHasNumber.value = /[0-9]/.test(password);
  // Common special characters. Adjust if needed.
  passwordHasSpecialChar.value = /[!@#$%^&*()_+~`|}{[\]:;?><,./-]/.test(password);

  // Clear local error message if criteria are met, otherwise set it
  if (allPasswordCriteriaMet.value) {
    localErrors.value.password = '';
  } else {
    localErrors.value.password = 'Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character.';
  }
};

// Function to generate a strong password
const generatePassword = () => {
  const length = 12; // You can adjust the desired length
  const charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_+~`|}{[]:;?><,./-=";
  let newPassword = "";
  for (let i = 0, n = charset.length; i < length; ++i) {
    newPassword += charset.charAt(Math.floor(Math.random() * n));
  }
  form.value.password = newPassword;
  form.value.password_confirmation = newPassword; // Auto-fill confirmation
  errors.value.password = ''; // Clear any previous errors
  errors.value.password_confirmation = '';
  localErrors.value.password = ''; // Clear local error as well
  validatePasswordCriteria(); // Validate the generated password
  showNotification('success', 'New password generated!');
};


const handleSubmit = async () => {
  errors.value = {
    current_password: '',
    password: '',
    password_confirmation: ''
  }
  localErrors.value.password = ''; // Clear local password error at the start of submission
  isSubmitting.value = true;
  formSubmitted.value = true; // Set form as submitted to display criteria list

  let hasError = false;

  if (!form.value.current_password) {
    errors.value.current_password = 'Current password is required.';
    hasError = true;
  }

  // Validate password criteria before submission
  validatePasswordCriteria();
  if (!allPasswordCriteriaMet.value) {
    hasError = true;
    // localErrors.value.password already set by validatePasswordCriteria()
  }

  if (form.value.password !== form.value.password_confirmation) {
    errors.value.password_confirmation = 'New passwords do not match.';
    hasError = true;
  }

  if (hasError) {
    isSubmitting.value = false;
    showNotification('warning', 'Please correct the highlighted errors.');
    return;
  }

  const formData = new FormData();
  formData.append('_method', 'PUT');
  formData.append('current_password', form.value.current_password);
  formData.append('password', form.value.password);
  formData.append('password_confirmation', form.value.password_confirmation);

  try {
    await auth.updateProfile(formData);
    showNotification('success', 'Password updated successfully!');
    form.value.current_password = '';
    form.value.password = '';
    form.value.password_confirmation = '';
    // Reset validation criteria display
    formSubmitted.value = false;
    passwordLengthValid.value = false;
    passwordHasUppercase.value = false;
    passwordHasLowercase.value = false;
    passwordHasNumber.value = false;
    passwordHasSpecialChar.value = false;

    setTimeout(() => {
      router.push('/client/profile');
    }, 1500);
  } catch (error) {
    console.error('Password update failed:', error);
    const apiErrors = error.response?.data?.errors;
    const generalMessage = error.response?.data?.message || 'Failed to update password. Please try again.';

    if (apiErrors) {
      if (apiErrors.current_password) {
        errors.value.current_password = apiErrors.current_password[0];
      }
      if (apiErrors.password) {
        // If API returns a specific password error, use it instead of local one
        errors.value.password = apiErrors.password[0]; // This will override localErrors.password if it exists
        localErrors.value.password = apiErrors.password[0]; // Ensure localErrors also gets the API message
      }
      showNotification('error', 'Validation failed. Please check your inputs.');
    } else if (generalMessage.includes('current password')) {
      errors.value.current_password = 'Current password is incorrect.';
      showNotification('error', 'Current password is incorrect.');
    } else {
      showNotification('error', generalMessage);
    }
  } finally {
    isSubmitting.value = false;
  }
}
</script>

<style scoped>
/* Base styles for the notification component to ensure it's visible and positioned correctly */
.fixed.top-4.right-4.z-50.space-y-3 > div {
  min-width: 250px;
  max-width: 350px;
  z-index: 1000;
}
</style>