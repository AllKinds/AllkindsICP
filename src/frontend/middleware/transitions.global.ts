const rules = [
    { from: "/contacts", to: "/discover", transition: "slide-left" },
    { from: "/discover", to: "/contacts", transition: "slide-right" },
    { from: "/select-team", to: "", transition: "page" },
    { from: "", to: "/select-team", transition: "page" },
    { from: "/answer-question/", to: "", transition: "page" },
    { from: "", to: "/answer-question/", transition: "page" },
]

export default defineNuxtRouteMiddleware((to, from) => {

    const order = from.path.localeCompare(to.path) > 0;
    let name = order ? 'slide-left' : 'slide-right';

    rules.forEach(rule => {
        if (from.path.startsWith(rule.from) && to.path.startsWith(rule.to)) {
            name = rule.transition;
        }
    });

    console.log("navigate from", from, "to", to, "with transition", name);

    to.meta.pageTransition = { name };
    from.meta.pageTransition = { name };
})