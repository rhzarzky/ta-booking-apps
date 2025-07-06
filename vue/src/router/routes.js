import LandingPage from '@/views/LandingPage.vue'
import LoginClient from '@/views/LoginClient.vue'
import RegisterClient from '@/views/RegisterClient.vue'
import DefaultLayout from '@/layouts/DefaultLayout.vue'
import Dashboard from '@/views/Client/Dashboard.vue'
import Service from '@/views/Client/Service.vue'
import History from '@/views/Client/History.vue'
import Activity from '@/views/Client/History.vue'
import Profile from '@/views/Client/Profile.vue'
import EditProfile from '@/views/Client/EditProfile.vue'
import ChangePassword from '@/views/Client/ChangePassword.vue'
import DetailService from '@/views/Client/DetailService.vue'
import DetailBooking from '@/views/Client/DetailBooking.vue'
import VerifyEmail from '@/views/VerifyEmail.vue'
import EmailVerificationSuccess from '@/views/EmailVerificationSuccess.vue'
import ForgotPassword from '@/views/ForgotPassword.vue'
import VerifyOtp from '@/views/VerifyOtp.vue'
import ResetPassword from '@/views/ResetPassword.vue'
import SuccessReset from '@/views/SuccessReset.vue'
import UnknownPage from '@/views/error/UnknownPage.vue'
import BookmarkPage from '@/views/Client/BookmarkPage.vue'

const routes = [
  {
    path: '/',
    name: 'landing-page',
    component: LandingPage,
    meta: {
      title: 'Landing Page',
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
    path: '/forgot-password',
    name: 'forgot-password',
    component: ForgotPassword,
    meta: {
      title: 'Lupa Password',
    },
  },
  {
    path: '/verify-otp',
    name: 'verify-otp',
    component: VerifyOtp,
    meta: {
      title: 'Verifikasi OTP',
    },
  },
  {
    path: '/reset-password',
    name: 'reset-password',
    component: ResetPassword,
    meta: {
      title: 'Reset Password',
    },
  },
  {
    path: '/success-reset',
    name: 'success-reset',
    component: SuccessReset,
    meta: {
      title: 'success reset',
    },
  },

  {
    path: '/:pathMatch(.*)*',
    name: '404 Error',
    component: UnknownPage,
    meta: {
      title: '404 Error',
      breadcrumbs: '404 Error',
      requiresAuth: false,
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
        path: 'service',
        name: 'client-service',
        component: Service,
        meta: {
          title: 'Service',
          breadcrumbs: 'Service',
        },
      },
      {
        path: 'history',
        name: 'client-history',
        component: History,
        meta: {
          title: 'History',
          breadcrumbs: 'History',
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
          breadcrumbs:  'Detail Service',
        },
      },
      {
        path: 'bookmarks', 
        name: 'client-bookmarks',
        component: BookmarkPage,
        meta: {
          title: 'My Bookmarks',
          breadcrumbs: 'Bookmarks',
        },
      },
    ],
  },
]

export default routes
