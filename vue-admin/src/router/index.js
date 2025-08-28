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
  document.title = `${to.meta?.title || 'Dashboard'} | Admin Panel`;

  const requiresAuth = to.matched.some((record) => record.meta.requiresAuth);
  const isAuthenticated = authServices.isAuthenticated();
  const userRole = authServices.getRole() || ''; 

  // redirect if route needs auth but not logged in
  if (requiresAuth && !isAuthenticated) {
    return next("/");
  }

  if (to.path === "/" && isAuthenticated) {
    if (userRole === "user") {
      next("/"); 
    } else {
      next("/dashboard");
    }
    return;
  }

  // role-based exclusion
  const excludedRoles = to.meta.excludeRole || [];
  if (excludedRoles.includes(userRole)) {
    return next("/"); // forbidden redirect
  }

  next();
});


export default router;
