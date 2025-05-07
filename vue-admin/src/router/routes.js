import ServicePage from "@/views/ServicePage.vue";
import AdminDashboard from "@/views/AdminDashboard.vue";
import LoginPage from "@/views/LoginPage.vue";
import UnknownPage from "@/views/error/UnknownPage.vue";

const routes = [{
        path: "/login-admin",
        name: "login",
        component: LoginPage,
        meta: {
            title: "login",
        },
    },
    {
        path: "/admin",
        name: "AdminDashboard",
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