import { backend } from "../../declarations/backend";

export default defineNuxtRouteMiddleware((to, from) => {
    return new Promise(async (resolve) => {
        if (to.path === '/login') {
            if (await checkAuth(null)) navigateTo('/welcome');
        }
        else if (!await checkAuth(null)) navigateTo('/login');

        resolve();
    })
})