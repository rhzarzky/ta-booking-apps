// src/router/index.js
import { createRouter, createWebHistory } from 'vue-router';
import routes from './routes';
import { authServices } from '../services/auth-services';

const router = createRouter({
  history: createWebHistory(),
  routes,
});

// Route Guard
router.beforeEach((to, from, next) => {
  const isLoggedIn = authServices.isAuthenticated();
  const requiresAuth = to.matched.some(record => record.meta.requiresAuth);

  if (requiresAuth && !isLoggedIn) {
    next('/login');
  } else {
    next();
  }

    document.title = `${to.meta.title} || Appointly`;
});

export default router;
