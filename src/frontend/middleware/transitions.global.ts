export default defineNuxtRouteMiddleware((to, from) => {

    const order = from.path.localeCompare(to.path) > 0;
    const name = order ? 'slide-left' : 'slide-right';

    console.log("navigate from", from, "to", to, "with transition", name);


    to.meta.pageTransition = {
        name
    };
})