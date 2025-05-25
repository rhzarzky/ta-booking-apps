import LandingPage from '@/views/LandingPage.vue';
import LoginClient from '@/views/LoginClient.vue';
import RegisterClient from '@/views/RegisterClient.vue';
import DefaultLayout from '@/layouts/DefaultLayout.vue';
import Dashboard from '@/views/Client/Dashboard.vue';
import Meeting from '@/views/Client/Service.vue';
import Activity from '@/views/Client/Activity.vue';
import Profile from '@/views/Client/Profile.vue';
import EditProfile from '@/views/Client/EditProfile.vue';
import ChangePassword from '@/views/Client/ChangePassword.vue';
import DetailService from '@/views/Client/DetailService.vue';
import DetailBooking from '@/views/Client/DetailBooking.vue';
import VerifyEmail from '@/views/VerifyEmail.vue';
import EmailVerificationSuccess from '@/views/EmailVerificationSuccess.vue';

const routes = [
  {
    path: '/',
    name: 'landing-page',
    component: LandingPage,
    meta: {
      title: 'Landing Page'
    },
  },
  {
    path: '/login',
    name: 'login',
    component: LoginClient,
    meta: {
      title: 'Login',
    },
  },
  {
    path: '/register',
    name: 'register',
    component: RegisterClient,
    meta: {
      title: 'Register',
    },
  },
  {
    path: '/verify-email',
    name: 'verify-email',
    component: VerifyEmail,
    meta: {
      title: 'Verifikasi Email',
    },
  },
  {
    path: '/email-verified',
    name: 'email-verified',
    component: EmailVerificationSuccess,
    meta: {
      title: 'Email Terverifikasi',
    },
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
        meta: {
          title: 'Dashboard ',
          breadcrumbs: 'Dashboard',
        },
      },
      {
        path: 'meeting',
        name: 'client-meeting',
        component: Meeting,
        meta: {
          title: 'Service',
          breadcrumbs: 'Service',
        },
      },
      {
        path: 'activity',
        name: 'client-activity',
        component: Activity,
        meta: {
          title: 'Activity',
          breadcrumbs: 'Activity',
        },
      },
      {
        path: 'profile',
        name: 'client-profile',
        component: Profile,
        meta: {
          title: 'User Profile',
          breadcrumbs: 'Profile',
        },
      },
      {
        path: 'edit-profile',
        name: 'client-edit-profile',
        component: EditProfile,
        meta: {
          title: 'Edit Profile',
          breadcrumbs: 'Edit Profile',
        },
      },
      {
        path: 'change-password',
        name: 'client-change-password',
        component: ChangePassword,
        meta: {
          title: 'Change Password',
          breadcrumbs: 'Change Password',
        },
      },
      {
        path: 'detail-booking/:id',
        name: 'client-detail-booking',
        component: DetailBooking,
        props: true,
        meta: {
          title: 'Booking Details',
          breadcrumbs: 'Detail Booking',
        },
      },
      {
        path: 'detail-service/:id',
        name: 'client-detail-service',
        component: DetailService,
        meta: {
          title: 'Service Details',
          breadcrumbs: 'Detail Service',
        },
      },
    ],
  },
];

export default routes;
