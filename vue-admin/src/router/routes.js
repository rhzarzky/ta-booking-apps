import ServicePage from "@/views/ServicePage.vue";
import AdminDashboard from "@/views/AdminDashboard.vue";
import LoginPage from "@/views/LoginPage.vue";
import UserPage from "@/views/UserPage.vue";
import UnknownPage from "@/views/error/UnknownPage.vue";
import CreateService from "@/views/CreateService.vue";

const routes = [{
        path: "/login-admin",
        name: "Login",
        component: LoginPage,
        meta: {
            title: "Login",
        },
    },
    {
        path: "/admin",
        name: "Admin Dashboard",
        component: AdminDashboard,
        meta: {
            requiresAuth: true,
            excludeRole: ["user"], 
            title: "Admin Dashboard",
        },
    },
    {
        path: "/service",
        name: "Service",
        component: ServicePage,
        meta: {
            title: "Service",
            excludeRole: ["user"], 
            requiresAuth: true,
        },
    },
    {
        path: "/create-service",
        name: "Create Service",
        component: CreateService,
        meta: {
            title: "Create Service",
            breadcrumbs: "Create Service",
            excludeRole: ["user"], 
            requiresAuth: true,
        },
    },
    {
        path: "/user-list",
        name: "User List",
        component: UserPage,
        meta: {
            title: "User List",
            excludeRole: ["user"], 
            requiresAuth: true,
        },
    },
    {
        path: "/:pathMatch(.*)*",
        name: "404 Error",
        component: UnknownPage,
        meta: {
            title: "404 Error",
            breadcrumbs: "404 Error",
            requiresAuth: false,
        },
    },
];

export default routes;