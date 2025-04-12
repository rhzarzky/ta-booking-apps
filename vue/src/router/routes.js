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
    name: 'landing-page',
    component: LandingPage,
  },
  {
    path: '/login',
    name: 'login',
    component: LoginClient,
  },
  {
    path: '/register',
    name: 'register',
    component: RegisterClient,
  },
  {
    path: '/client',
    component: DefaultLayout,
    meta: { requiresAuth: true },
    children: [
      {
        path: 'dashboard',
        name: 'client-dashboard',
        component: Dashboard,
      },
      {
        path: 'meeting',
        name: 'client-meeting',
        component: Meeting,
      },
      {
        path: 'activity',
        name: 'client-activity',
        component: Activity,
      },
      {
        path: 'profile',
        name: 'client-profile',
        component: Profile,
      },
      {
        path: 'edit-profile',
        name: 'client-edit-profile',
        component: EditProfile,
      },
      {
        path: 'detail-booking',
        name: 'client-detail-booking',
        component: DetailBooking,
      },
    ],
  },
];

export default routes;
