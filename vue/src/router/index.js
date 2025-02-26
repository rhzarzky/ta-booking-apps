import { createRouter, createWebHistory } from 'vue-router';
import LandingPage from '../views/Client/LandingPage.vue';
import Login from '../views/Client/Login.vue';
import Register from '../views/Client/Register.vue';

const routes = [
  { path: '/', component: LandingPage },
  { path: '/login', component: Login },
  { path: '/register', component: Register },


];

const router = createRouter({
  history: createWebHistory(),
  routes
});

export default router;
