const rules = [
    { from: "", to: "", transition: "" },
    { from: "", to: "", transition: "" },
    { from: "", to: "", transition: "" },
    { from: "", to: "", transition: "" },
]

export default defineNuxtRouteMiddleware((to, from) => {

    const order = from.path.localeCompare(to.path) > 0;
    let name = order ? 'slide-left' : 'slide-right';

    if (from.path === '/select-team') name = 'page';

    console.log("navigate from", from, "to", to, "with transition", name);

    to.meta.pageTransition = { name };
    from.meta.pageTransition = { name };
})