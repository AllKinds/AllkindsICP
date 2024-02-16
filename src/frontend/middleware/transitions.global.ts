const rules = [
    { from: "/logged-in", to: "", transition: "slide-left", reverse: "slide-left" },
    { from: "/discover", to: "/contacts", transition: "slide-left", reverse: "slide-right" },
    { from: "/select-team", to: "", transition: "page", reverse: "page" },
    { from: "/answer-question/", to: "", transition: "page", reverse: "page" },
    { from: "/ask-question", to: "/discover", transition: "slide-left", reverse: "slide-right" },

    { from: "/questions", to: "/my-profile", transition: "page", reverse: "page" },
    { from: "/my-profile", to: "/settings", transition: "slide-left", reverse: "slide-right" },
    { from: "/settings", to: "/questions", transition: "page", reverse: "page" },
]

export default defineNuxtRouteMiddleware((to, from) => {

    const order = from.path.localeCompare(to.path) > 0;
    let name = order ? 'slide-left' : 'slide-right';

    rules.forEach(rule => {
        if (from.path.startsWith(rule.from) && to.path.startsWith(rule.to)) {
            name = rule.transition;
        }
    });

    rules.forEach(rule => {
        if (from.path.startsWith(rule.to) && to.path.startsWith(rule.from) && rule.reverse) {
            name = rule.reverse;
        }
    });

    console.log("navigate from", from, "to", to, "with transition", name);

    to.meta.pageTransition = { name };
    from.meta.pageTransition = { name };
})
