export type ColorName = "pink" | "red" | "orange" | "yellow" | "green" | "blue" | "indigo" | "purple" | "black" | "white"
export type Color = { color: string, bg: string, fg: string, fgBtn: string }

export const colors: { [key: string]: Color } = {
    white: { color: "f-white", bg: "#FFFFFF", fg: "black", fgBtn: "white" },
    black: { color: "f-black", bg: "#000000", fg: "white", fgBtn: "black" },
    purple: { color: "f-purple", bg: "#C79BFF", fg: "black", fgBtn: "white" },
    indigo: { color: "f-indigo", bg: "#5155C1", fg: "white", fgBtn: "black" },
    blue: { color: "f-blue", bg: "#60ACF1", fg: "black", fgBtn: "white" },
    green: { color: "g-green", bg: "#51C171", fg: "white", fgBtn: "black" },
    yellow: { color: "f-yellow", bg: "#FFBB54", fg: "black", fgBtn: "white" },
    orange: { color: "f-orange", bg: "#FF6854", fg: "black", fgBtn: "white" },
    red: { color: "f-red", bg: "#FF5754", fg: "white", fgBtn: "black" },
    pink: { color: "f-pink", bg: "#F99DAB", fg: "black", fgBtn: "white" },
}

export const getColor = (color: ColorName): Color => {
    const c = colors[color];
    return c ?? colors['black']
}

export type Icon = { to: string, icon: string };

// Icon mappings. More specific ones must be above.
export const icons = [
    { to: "/discover", icon: "prime:users" },
    { to: "/questions", icon: "mynaui:layers-three" },
    { to: "/contacts", icon: "tabler:user-check" },
    { to: "/select-team", icon: "clarity:rack-server-line" },
    { to: "/settings", icon: "ph-gear" },
    { to: "/", icon: "gg:shape-hexagon" },
    { to: "x", icon: "ph:x" },
    { to: "back", icon: "ic:round-arrow-back" },
    { to: "loading", icon: "line-md:loading-alt-loop" },
    { to: "remove-user", icon: "prime:user-minus" },
    { to: "plus", icon: "ph:plus-circle"},
    { to: "minus", icon: "ph:minus-circle"},
    { to: "kin", icon: "gg:shape-hexagon"},
    { to: "kin-small", icon: "mdi:hexagon-outline"},
    { to: "info", icon: "tabler:info-hexagon"},
    { to: "loading", icon: "line-md:loading-alt-loop"},
    { to: ">", icon: "material-symbols:arrow-forward-ios"},
    { to: "users", icon: "prime:users"},
    { to: "checkedbox", icon: "tabler:checkbox"},
    { to: "checkbox", icon: "ci:checkbox-unchecked"},
    { to: "gear", icon: "ph:gear"},
    { to: "admin", icon: "tabler:user-shield"},
    { to: "user-confirmed", icon: "tabler:user-check"},
    { to: "delete", icon: "tabler:trash"},
    { to: "refresh", icon: "charm:refresh"},
    { to: "user-add", icon: "prime:user-plus"},
    { to: "user-remove", icon: "prime:user-minus"},
    { to: "team-select", icon: "mynaui:layers-three"},
    { to: "star-empty", icon: "oui:star-empty-space"},
    { to: "star", icon: "oui:star-filled-space"},
];

export const getIcon = (path: string): Icon => {
    const i = icons.find((x) => path.startsWith(x.to));
    if(i) return i;
    console.error("invalid icon name", path, "not found in", icons);
    return { to: "", icon: "gg:shape-hexagon" };
}
