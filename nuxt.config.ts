import { defineNuxtConfig } from "nuxt/config";
import { dfx_env } from "./env_loader";


// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
    srcDir: './src/frontend',
    devtools: { enabled: true },
    //ssr: false,
    modules: [
        '@nuxtjs/tailwindcss',
        'nuxt-icon',
        '@pinia/nuxt',
        '@nuxtjs/google-fonts',
    ],
    runtimeConfig: {
        public: dfx_env()
    },
    app:
    {
        head: {
            titleTemplate: (t) => { return t ? `${t} - Allkinds` : 'Allkinds' },
        },
    },
    googleFonts: {
        download: true,
        families: {
            'Open+Sans': [300, 400, 500, 600, 700, 800],
        }
    },
})
