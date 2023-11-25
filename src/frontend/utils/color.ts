export type ColorName = "pink" | "red" | "orange" | "yellow" | "green" | "blue" | "indigo" | "purple" | "black" | "white"
export type Color = { color: string }

export const colors: { [key: string]: Color } = {
    white: { color: "bg-white text-black border-gray-500 placeholder-gray-500" },
    black: { color: "bg-slate-900 text-white" },
    purple: { color: "bg-purple-500 text-slate-900 placeholder-gray-400" },
    indigo: { color: "bg-indigo-500 text-white placeholder-gray-400" },
    blue: { color: "bg-blue-500 text-white placeholder-gray-300" },
    green: { color: "bg-green-500 text-slate-900 placeholder-gray-500" },
    yellow: { color: "bg-yellow-500 text-slate-900 placeholder-gray-500" },
    orange: { color: "bg-orange-500 text-slate-900 placeholder-gray-500" },
    red: { color: "bg-red-500 text-white placeholder-gray-500" },
    pink: { color: "bg-pink-500 text-slate-900 placeholder-gray-500" },
}

export const getColor = (color: ColorName): Color => {
    const c = colors[color];
    if (c) return c;
    return colors['black']
}