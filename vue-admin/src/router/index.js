import { createRouter, createWebHistory } from "vue-router";
import routes from "./routes";

import { authServices } from "@/services/auth-services";

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes,
  scrollBehavior(to, from, savedPosition) {
    return savedPosition || { left: 0, top: 0 };
  },
});

// Middleware global for authentication and setting pages
router.beforeEach((to, from, next) => {
  document.title = `${to.meta.title} | Admin Panel`;

  const requiresAuth = to.matched.some((record) => record.meta.requiresAuth);
  const isAuthenticated = authServices.isAuthenticated();
  const userRole = authServices.getRole(); // e.g., 'admin', 'user', etc.

  if (requiresAuth && !isAuthenticated) {
    next("/login-admin");
    return;
  }

  if (to.path === "/login-admin" && isAuthenticated) {
    if (userRole === "user") {
      next("/"); // redirect regular user to user home
    } else {
      next("/service"); // redirect admin/verifikator to admin
    }
    return;
  }

  const excludedRoles = to.meta.excludeRole || [];
  if (excludedRoles.includes(userRole)) {
    next("/"); // redirect forbidden user to default page
    return;
  }

  next();
});


export default router;
