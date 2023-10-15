import { defineNuxtConfig } from "nuxt/config";

const network = process.env["DFX_NETWORK"] ?? "local";
const isDev = network !== "ic";
const isStaging = network === "staging";

const II_URL = isDev ? "" : "";
const NFID_URL = isDev ? "" : "";

// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
    srcDir: './src/frontend',
    devtools: { enabled: true },
    modules: [
        '@nuxtjs/tailwindcss',
        'nuxt-icon',
    ],
    runtimeConfig: {
        public: {
            network, isDev, isStaging,
            II_URL
        }
    }
})
