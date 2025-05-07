<script setup>
import { onClickOutside } from "@vueuse/core";
import { useAuthStore } from "@/stores/auth";
import { ref, computed, onMounted } from "vue";
import { storeToRefs } from "pinia";

import { useSidebarStore } from "@/stores/sidebar";
import SidebarItem from "./SidebarItem.vue";

const authStore = useAuthStore();
const { currentUser } = storeToRefs(authStore);
const { fetchCurrentUserApi } = authStore;

const target = ref(null);
const sidebarStore = useSidebarStore();

onClickOutside(target, () => {
  sidebarStore.isSidebarOpen = false;
});

const fetchCurrentUser = async () => {
  try {
    await fetchCurrentUserApi(); // Hanya dapatkan infomation user yang login
  } catch (err) {
    console.error("failed to fetch current user", err);
  }
};

// dan pastikan di modal role access control
const closeRoleAccessControl = () => {
  isVisible.value = false; // Tutup modal
  fetchCurrentUser(); // Refresh untuk memastikan sidebar menampilkan data user yang login
};

const userInfo = computed(() => {
  return {
    name: currentUser.value?.name || "Guest",
    role: (currentUser.value?.role && currentUser.value.role[0]) || "No role",
    permission: currentUser.value?.permissions || "No permission",
  };
});

onMounted(async () => {
  await fetchCurrentUser();
});

const baseMenuItems = ref([
  {
    name: "Menu",
    menuItems: [
      {
        icon: `<svg
                  class="fill-current"
                  width="18"
                  height="18"
                  viewBox="0 0 18 18"
                  fill="none"
                  xmlns="http://www.w3.org/2000/svg"
                >
                  <path
                    d="M6.10322 0.956299H2.53135C1.5751 0.956299 0.787598 1.7438 0.787598 2.70005V6.27192C0.787598 7.22817 1.5751 8.01567 2.53135 8.01567H6.10322C7.05947 8.01567 7.84697 7.22817 7.84697 6.27192V2.72817C7.8751 1.7438 7.0876 0.956299 6.10322 0.956299ZM6.60947 6.30005C6.60947 6.5813 6.38447 6.8063 6.10322 6.8063H2.53135C2.2501 6.8063 2.0251 6.5813 2.0251 6.30005V2.72817C2.0251 2.44692 2.2501 2.22192 2.53135 2.22192H6.10322C6.38447 2.22192 6.60947 2.44692 6.60947 2.72817V6.30005Z"
                    fill=""
                  />
                  <path
                    d="M15.4689 0.956299H11.8971C10.9408 0.956299 10.1533 1.7438 10.1533 2.70005V6.27192C10.1533 7.22817 10.9408 8.01567 11.8971 8.01567H15.4689C16.4252 8.01567 17.2127 7.22817 17.2127 6.27192V2.72817C17.2127 1.7438 16.4252 0.956299 15.4689 0.956299ZM15.9752 6.30005C15.9752 6.5813 15.7502 6.8063 15.4689 6.8063H11.8971C11.6158 6.8063 11.3908 6.5813 11.3908 6.30005V2.72817C11.3908 2.44692 11.6158 2.22192 11.8971 2.22192H15.4689C15.7502 2.22192 15.9752 2.44692 15.9752 2.72817V6.30005Z"
                    fill=""
                  />
                  <path
                    d="M6.10322 9.92822H2.53135C1.5751 9.92822 0.787598 10.7157 0.787598 11.672V15.2438C0.787598 16.2001 1.5751 16.9876 2.53135 16.9876H6.10322C7.05947 16.9876 7.84697 16.2001 7.84697 15.2438V11.7001C7.8751 10.7157 7.0876 9.92822 6.10322 9.92822ZM6.60947 15.272C6.60947 15.5532 6.38447 15.7782 6.10322 15.7782H2.53135C2.2501 15.7782 2.0251 15.5532 2.0251 15.272V11.7001C2.0251 11.4188 2.2501 11.1938 2.53135 11.1938H6.10322C6.38447 11.1938 6.60947 11.4188 6.60947 11.7001V15.272Z"
                    fill=""
                  />
                  <path
                    d="M15.4689 9.92822H11.8971C10.9408 9.92822 10.1533 10.7157 10.1533 11.672V15.2438C10.1533 16.2001 10.9408 16.9876 11.8971 16.9876H15.4689C16.4252 16.9876 17.2127 16.2001 17.2127 15.2438V11.7001C17.2127 10.7157 16.4252 9.92822 15.4689 9.92822ZM15.9752 15.272C15.9752 15.5532 15.7502 15.7782 15.4689 15.7782H11.8971C11.6158 15.7782 11.3908 15.5532 11.3908 15.272V11.7001C11.3908 11.4188 11.6158 11.1938 11.8971 11.1938H15.4689C15.7502 11.1938 15.9752 11.4188 15.9752 11.7001V15.272Z"
                    fill=""
                  />
                </svg>`,
        label: "Dashboard",
        route: "/dashboard",
        // requiredPermission: "update issue",
        // children: [{ label: "sentry" }],
      },
      {
        icon: `<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
              <rect x="18" y="7" width="4" height="13" rx="1" stroke="#EFEFEF" stroke-linejoin="round"/>
              <rect x="10" y="13" width="4" height="7" rx="1" stroke="#EFEFEF" stroke-linejoin="round"/>
              <rect x="2" y="9" width="4" height="11" rx="1" stroke="#EFEFEF" stroke-linejoin="round"/>
              </svg>
              `,
        label: "Service",
        route: "/service",
        // requiredPermission: "update issue",
        // children: [{ label: "sentry" }],
      },
      {
        icon: `<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M11.5 8.5V4.5" stroke="#EFEFEF" stroke-linecap="round"/>
                <path d="M6.5 14.5V18.5" stroke="#EFEFEF" stroke-linecap="round"/>
                <path d="M16.5001 16.4998L16.5001 18.5" stroke="#EFEFEF" stroke-linecap="round"/>
                <path d="M11.5 18.5V12.5" stroke="#EFEFEF" stroke-linecap="round"/>
                <path d="M6.5 4.5V10.5" stroke="#EFEFEF" stroke-linecap="round"/>
                <path d="M16.5 4.5V12.5" stroke="#EFEFEF" stroke-linecap="round"/>
                <path d="M9.5 8.5L13.5 8.5" stroke="#EFEFEF" stroke-linecap="round"/>
                <path d="M4.5 14.5L8.5 14.5" stroke="#EFEFEF" stroke-linecap="round"/>
                <path d="M14.5 16.5H18.5" stroke="#EFEFEF" stroke-linecap="round"/>
                </svg>
                `,
        label: "Booking",
        route: "/booking",
        // requiredPermission: "update issue",
        // children: [{ label: "sentry" }],
      },
    ],
  },
]);

const adminMenuItems = ref([
  {
    name: "User",
    menuItems: [
      {
        icon: `<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
        <path d="M14.4375 7.50001C14.4375 7.35082 14.4968 7.20775 14.6023 7.10226C14.7078 6.99677 14.8509 6.93751 15 6.93751H23.25C23.3992 6.93751 23.5423 6.99677 23.6478 7.10226C23.7533 7.20775 23.8125 7.35082 23.8125 7.50001C23.8125 7.64919 23.7533 7.79227 23.6478 7.89775C23.5423 8.00324 23.3992 8.06251 23.25 8.06251H15C14.8509 8.06251 14.7078 8.00324 14.6023 7.89775C14.4968 7.79227 14.4375 7.64919 14.4375 7.50001ZM23.25 11.4375H15C14.8509 11.4375 14.7078 11.4968 14.6023 11.6023C14.4968 11.7077 14.4375 11.8508 14.4375 12C14.4375 12.1492 14.4968 12.2923 14.6023 12.3978C14.7078 12.5032 14.8509 12.5625 15 12.5625H23.25C23.3992 12.5625 23.5423 12.5032 23.6478 12.3978C23.7533 12.2923 23.8125 12.1492 23.8125 12C23.8125 11.8508 23.7533 11.7077 23.6478 11.6023C23.5423 11.4968 23.3992 11.4375 23.25 11.4375ZM23.25 15.9375H17.25C17.1009 15.9375 16.9578 15.9968 16.8523 16.1023C16.7468 16.2077 16.6875 16.3508 16.6875 16.5C16.6875 16.6492 16.7468 16.7923 16.8523 16.8978C16.9578 17.0032 17.1009 17.0625 17.25 17.0625H23.25C23.3992 17.0625 23.5423 17.0032 23.6478 16.8978C23.7533 16.7923 23.8125 16.6492 23.8125 16.5C23.8125 16.3508 23.7533 16.2077 23.6478 16.1023C23.5423 15.9968 23.3992 15.9375 23.25 15.9375ZM14.0447 17.8594C14.0632 17.9309 14.0674 18.0054 14.0571 18.0785C14.0468 18.1517 14.0222 18.2221 13.9846 18.2857C13.9471 18.3494 13.8974 18.405 13.8384 18.4494C13.7794 18.4939 13.7122 18.5262 13.6407 18.5447C13.5691 18.5632 13.4947 18.5674 13.4215 18.557C13.3484 18.5467 13.278 18.5221 13.2143 18.4846C13.1507 18.4471 13.0951 18.3974 13.0506 18.3384C13.0062 18.2794 12.9738 18.2122 12.9554 18.1406C12.3469 15.7772 10.0529 14.0625 7.50005 14.0625C4.94724 14.0625 2.65317 15.7772 2.04474 18.1397C2.02627 18.2112 1.99389 18.2784 1.94946 18.3374C1.90502 18.3965 1.8494 18.4461 1.78576 18.4837C1.72213 18.5212 1.65172 18.5458 1.57857 18.5561C1.50542 18.5664 1.43095 18.5622 1.35942 18.5438C1.28789 18.5253 1.2207 18.4929 1.16168 18.4485C1.10267 18.404 1.05298 18.3484 1.01546 18.2848C0.977938 18.2211 0.953319 18.1507 0.943007 18.0776C0.932696 18.0044 0.936893 17.93 0.95536 17.8584C1.49349 15.7697 3.11161 14.1019 5.14317 13.3584C4.36503 12.8506 3.77172 12.1051 3.45159 11.2328C3.13145 10.3605 3.10161 9.40812 3.36652 8.5175C3.63142 7.62688 4.17689 6.84564 4.92171 6.29011C5.66654 5.73457 6.57087 5.43446 7.50005 5.43446C8.42923 5.43446 9.33356 5.73457 10.0784 6.29011C10.8232 6.84564 11.3687 7.62688 11.6336 8.5175C11.8985 9.40812 11.8686 10.3605 11.5485 11.2328C11.2284 12.1051 10.6351 12.8506 9.85692 13.3584C11.8866 14.1028 13.5075 15.7706 14.0447 17.8594ZM7.50005 12.9375C8.13048 12.9375 8.74675 12.7506 9.27093 12.4003C9.79511 12.0501 10.2037 11.5523 10.4449 10.9698C10.6862 10.3874 10.7493 9.74647 10.6263 9.12816C10.5033 8.50984 10.1997 7.94188 9.75395 7.4961C9.30817 7.05032 8.74021 6.74674 8.1219 6.62375C7.50358 6.50076 6.86268 6.56389 6.28024 6.80514C5.6978 7.0464 5.19999 7.45495 4.84974 7.97913C4.49949 8.50331 4.31255 9.11958 4.31255 9.75001C4.31255 10.5954 4.64837 11.4061 5.24614 12.0039C5.84392 12.6017 6.65467 12.9375 7.50005 12.9375Z" fill="#EFEFEF"/>
        </svg>
        `,
        label: "Users ",
        route: "/users-list",
        requiredPermission: "show user",
      },
      // {
      //   icon: `<svg xmlns="http://www.w3.org/2000/svg" width="24px" height="24px" viewBox="0 0 16 16">
      //           <path fill="none" stroke="currentColor" d="M8 4.5h6m-12 0h2.5m0 0a2 2 0 1 0 4 0a2 2 0 0 0-4 0Zm-2.5 7h6m3.5 0H14m-2.5 0a2 2 0 1 1-4 0a2 2 0 0 1 4 0Z" />
      //         </svg>
      //   `,
      //   label: "Control Access",
      //   route: "/control-access",
      // },
    ],
  },
]);
const filterMenuItemsByPermission = (menuItems, checkPermissions = true) => {
  if (!checkPermissions) {
    return menuItems;
  }

  return menuItems
    .map((group) => ({
      ...group,
      menuItems: group.menuItems.filter(
        (item) => !item.requiredPermission || userInfo.value.permission.includes(item.requiredPermission)
      ),
    }))
    .filter((group) => group.menuItems.length > 0);
};

const menuGroups = computed(() => {
  const baseMenuFiltered = filterMenuItemsByPermission(
    baseMenuItems.value,
    false
  );
  const adminMenuFiltered = filterMenuItemsByPermission(
    adminMenuItems.value,
    true
  );

  return [...baseMenuFiltered, ...adminMenuFiltered];
});
</script>

<template>
  <aside
    class="absolute left-0 top-0 z-50 flex h-screen w-64 flex-col overflow-y-hidden bg-gradient-to-b from-cobalt-950 to-cobalt-900 border-r-[1px] border-wildsand-200 duration-300 ease-linear lg:static lg:translate-x-0 rounded-tr-xl rounded-br-xl"
    :class="{
      'translate-x-0': sidebarStore.isSidebarOpen,
      '-translate-x-full': !sidebarStore.isSidebarOpen,
    }" ref="target">
    <!-- sidebar header start -->
    <div class="flex items-center justify-between gap-2 p-6">
      <router-link to="/dashboard">
        <img src="@/assets/image/logo-gmed.png" alt="" class="w-32" />
      </router-link>
      <button class="block lg:hidden" @click="sidebarStore.isSidebarOpen = false">
        <svg class="text-cobalt-50" xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" viewBox="0 0 1024 1024">
          <path fill="currentColor"
            d="M752.145 0c8.685 0 17.572 3.434 24.237 10.099c13.33 13.33 13.33 35.143 0 48.473L320.126 515.03l449.591 449.591c13.33 13.33 13.33 35.144 0 48.474s-35.142 13.33-48.472 0L247.418 539.268c-13.33-13.33-13.33-35.144 0-48.474L727.91 10.1C734.575 3.435 743.46.002 752.146.002z" />
        </svg>
      </button>
    </div>
    <!-- sidebar header end -->

    <div class="no-scrollbar flex flex-col overflow-y-auto duration-300 ease-linear">
      <!-- sidebar Menu start -->
      <nav class="p-4 lg:px-6">
        <div v-for="menuGroup in menuGroups" :key="menuGroup.name">
          <div class="">
            <h3 class="mb-2 ml-4 text-sm font-medium text-cobalt-50">
              {{ menuGroup.name }}
            </h3>
            <ul class="mb-6 flex flex-col gap-2">
              <SidebarItem v-for="(menuItem, index) in menuGroup.menuItems" :item="menuItem" :key="index"
                :index="index" />
            </ul>
          </div>
        </div>
      </nav>
      <!-- sidebar Menu end -->
    </div>
  </aside>
</template>
