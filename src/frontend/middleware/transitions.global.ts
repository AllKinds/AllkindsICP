// mapping to determine order of pages
const mapping = [
    { path: "/team", pos: "/main0.0" },
    { path: "/questions", pos: "/main1.0" },
    { path: "/discover", pos: "/main2.0" },
    { path: "/contacts/", pos: "/main3.2" },
    { path: "/contacts", pos: "/main3.0" },
    { path: "/chat/", pos: "/main3.1" },
    { path: "/my-profile", pos: "/main4.0" },
    { path: "/settings", pos: "/main4.1" },
]
const rules = [
    { from: "/logged-in", to: "", transition: "slide-left", reverse: "slide-left" },
    { from: "/verify", to: "/team", transition: "slide-left", reverse: "slide-left" },
    { from: "/select-team", to: "", transition: "page", reverse: "page" },
    { from: "/answer-question", to: "/questions", transition: "page", reverse: "page" },
    { from: "/answer-question", to: "/answer-question", transition: "page", reverse: "page" },
    { from: "/register", to: "", transition: "page", reverse: "page" },
]

export default defineNuxtRouteMiddleware((to, from) => {
    // default transition based page name and mapping
    let f = from.path;
    let t = to.path;
    for (let o of mapping) {
        if (f.startsWith(o.path)) {
            f = o.pos + f;
        }
        if (t.startsWith(o.path)) {
            t = o.pos + t;
        }
    }

    const order = f.localeCompare(t) < 0;
    let name = order ? 'slide-left' : 'slide-right';
    let reason = "compare " + f + " to " + t;

    // custom rules per page
    for (let rule of rules) {
        if (from.path.startsWith(rule.from) && to.path.startsWith(rule.to)) {
            name = rule.transition;
            reason = "rule " + JSON.stringify(rule);
            break;
        }
    };

    for (let rule of rules) {
        if (from.path.startsWith(rule.to) && to.path.startsWith(rule.from) && rule.reverse) {
            name = rule.reverse;
            reason = "rule reverse " + JSON.stringify(rule);
            break;
        }
    };

    console.log("navigate from", from.fullPath, "to", to.fullPath, "with transition", name, "due to", reason);

    to.meta.pageTransition = { name };
    from.meta.pageTransition = { name };
})
