<template>
  <div class="default-layout flex">
    <SidebarArea />
    <div class="content flex-1 p-8">
      <router-view />
    </div>
  </div>
</template>

<script>
import SidebarArea from '@/components/Client/Sidebar/SidebarArea.vue';  

export default {
  name: 'DefaultLayout',
  components: {
    SidebarArea,
  },
};
</script>

<style scoped>
.default-layout {
  min-height: 100vh;
}
</style>
