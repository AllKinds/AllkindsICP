export default defineNuxtRouteMiddleware((to, from) => {
    console.log("navigate from", from, "to", to);
    debugger;
    to.meta.pageTransition = {
        name: +to.params.id > +from.params.id ? 'slide-left' : 'slide-right'
    };
})