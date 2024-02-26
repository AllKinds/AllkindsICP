<script lang="ts" setup>
import { themeChange } from "theme-change";
import 'vue3-toastify/dist/index.css';
import { inBrowser } from "./composables/appState";

const app = useAppState();
const auth = useAuthState();

onMounted(() => {
    themeChange(false);
});

onNuxtReady(() => {
});


const style = () =>
    "font-family: Lexend, sans-serif;"
    + "font-optical-sizing: auto;"
    + "font-weight: 600;"
    + "height: 100vh;"
    + "font-style: normal;";

const debug = ref(false);

if (inBrowser()) {
    if (auth.loggedIn) {
        console.log("load user data")
        app.loadUser(undefined, false);
    }

    try {
        const body = document.getElementsByTagName("body")[0];
        body.onkeyup = (e) => {
            if (e.ctrlKey && e.key == '.') {
                debug.value = !debug.value;
                if (debug.value) body.classList.add("debug")
                else body.classList.remove("debug")
            }
        }
    } catch { }
}

</script>

<template>
    <div class="h-full transition-all flex flex-col overflow-x-hidden" :style="style()">
        <NuxtLayout>
            <div class="w-full h-72 overflow-y-auto flex-grow scrollbar-none overflow-x-hidden">
                <div class="m-auto max-w-lg h-full flex flex-col items-center p-3">
                    <NuxtPage />
                </div>
            </div>
            <pre class="absolute top-1 right-1 text-xs opacity-40" v-if="debug">{{ $route.path }} {{ $route.meta }}</pre>
            <FooterMenu class="max-w-lg self-center" v-if="$route.meta.footerMenu" />
        </NuxtLayout>
    </div>
</template>


<style>
@import url('https://fonts.googleapis.com/css2?family=Grape+Nuts&display=swap');
@import url('https://fonts.googleapis.com/css2?family=Grape+Nuts&family=Lexend&display=swap');
@import url("~/public/app.css");

/* Transitions */
.page-enter-active,
.page-leave-active {
    transition: all 0.15s;
    transform: translateY(0%);
}

.page-enter-from {
    opacity: 0;
    transform: translateY(+10%) scale(0.5);
    filter: blur(1rem);
    position: absolute;
    overflow: hidden;
}

.page-leave-to {
    opacity: 0;
    transform: translateY(-50%);
    filter: blur(1rem);
}

.slide-left-enter-active,
.slide-left-leave-active,
.slide-right-enter-active,
.slide-right-leave-active {
    transition: all 0.2s;
}

.slide-left-leave-to,
.slide-right-enter-from {
    opacity: 0;
    transform: translate(-200px, 0);
}

.slide-left-enter-from,
.slide-right-leave-to {
    opacity: 0;
    transform: translate(200px, 0);
}

/**/
</style>