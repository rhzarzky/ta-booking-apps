import { createRouter, createWebHistory } from 'vue-router';
import LandingPage from '@/views/LandingPage.vue';
import LoginClient from '@/views/LoginClient.vue';
import RegisterClient from '@/views/RegisterClient.vue';
import DefaultLayout from '@/layouts/DefaultLayout.vue';
import Dashboard from '@/views/Client/Dashboard.vue';
import Meeting from '@/views/Client/Meeting.vue';
import Activity from '@/views/Client/Activity.vue';
import Profile from '@/views/Client/Profile.vue';
import EditProfile from '@/views/Client/EditProfile.vue';
import DetailBooking from '@/views/Client/DetailBooking.vue'; 

const routes = [
  {
    path: '/',
    component: LandingPage,
  },
  {
    path: '/login',
    component: LoginClient,
  },
  {
    path: '/register',
    component: RegisterClient,
  },
  {
    path: '/client',
    component: DefaultLayout,
    children: [
      { path: 'dashboard', component: Dashboard },
      { path: 'meeting', component: Meeting },
      { path: 'activity', component: Activity },
      { path: 'profile', component: Profile },
      { path: 'edit-profile', component: EditProfile },
      { path: 'detail-booking', name: 'DetailBooking', component: DetailBooking }, 
    ],
  },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

export default router;
