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
    if (c) return c;
    return colors['black']
}
