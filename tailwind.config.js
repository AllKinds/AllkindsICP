module.exports = {
  plugins: [
    require("daisyui"),
    require('@tailwindcss/typography'),
  ],

  daisyui: {
    themes: [
      {
        allkinds: {
          "base-content": "#FEFEFE",
          "primary": "#343232",
          "primary-content": "#FEFEFE",
          "secondary": "#343232",
          "accent": "#343232",
          "neutral": "#272626",
          "base-100": "#000000",
          "info": "#3abff8",
          "success": "#36d399",
          "warning": "#fbbd23",
          "error": "#f87272",
          "--btn-text-case": "none",
        }
      },
      "dark",
      "light",
      "black",
    ],
  },
}
