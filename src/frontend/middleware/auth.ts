import { backend } from "../../declarations/backend";

export default defineNuxtRouteMiddleware((to, from) => {
    if (typeof window === 'undefined') { return }
    if (to.path === '/login') {
        if (isLoggedIn()) navigateTo('/welcome');
    }
    else if (!isLoggedIn()) navigateTo('/login');
    else console.log("logged in");
})