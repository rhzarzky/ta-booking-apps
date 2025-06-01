import ServicePage from "@/views/ServicePage.vue";
import AdminDashboard from "@/views/AdminDashboard.vue";
import LoginPage from "@/views/LoginPage.vue";
import UserPage from "@/views/UserPage.vue";
import UnknownPage from "@/views/error/UnknownPage.vue";
import CreateService from "@/views/CreateService.vue";
import EditUser from "@/views/EditUser.vue";
import ChangePasswordUser from "@/views/ChangePasswordUser.vue";
import CreateUser from "@/views/CreateUser.vue";
import CreateRole from "@/views/CreateRole.vue";
import EditService from "@/views/EditService.vue";
import BookingPage from "@/views/BookingPage.vue";

const routes = [
    {
        path: "/",
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
            breadcrumbs: "Admin Dashboard",
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
            breadcrumbs: "Service",
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
        path: "/edit-service/:id",
        name: "Edit Service",
        component: EditService,
        meta: {
            title: "Edit Service",
            breadcrumbs: "Edit Service",
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
            breadcrumbs: "User List",
            excludeRole: ["user"], 
            requiresAuth: true,
        },
    },
    {
        path: "/create-user",
        name: "Create User",
        component: CreateUser,
        meta: {
            title: "Create User",
            breadcrumbs: "Create User",
            excludeRole: ["user"], 
            requiresAuth: true,
        },
    },
    {
        path: "/create-role",
        name: "Create Role",
        component: CreateRole,
        meta: {
            title: "Create Role",
            breadcrumbs: "Create Role",
            excludeRole: ["user"], 
            requiresAuth: true,
        },
    },
    {
        path: "/edit-profile/:id",
        name: "Edit Profile",
        component: EditUser,
        meta: {
            title: "Edit Profile",
            breadcrumbs: "Edit Profile",
            excludeRole: ["user"], 
            requiresAuth: true,
        },
    },
    {
        path: "/change-password-user/:id",
        name: "Change Password User",
        component: ChangePasswordUser,
        meta: {
            title: "Change Password User",
            breadcrumbs: "Change Password User",
            excludeRole: ["user"], 
            requiresAuth: true,
        },
    },
    {
        path: "/booking",
        name: "Booking",
        component: () => BookingPage,
        meta: {
            title: "Booking",
            breadcrumbs: "Booking",
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