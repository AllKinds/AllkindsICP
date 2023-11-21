<script lang="ts" setup>
import { themeChange } from "theme-change";
import 'vue3-toastify/dist/index.css'
import { Effect } from "effect";

onMounted(() => {
    themeChange(false);
});

onNuxtReady(() => {
    Effect.runPromise(checkAuth(null));
});

const route = useRoute();
const app = useAppState();
const nuxt = useNuxtApp();

const page = route.path.length <= 1 ? "index" : route.path;

const style = "background-image: url('/figma/" + page + ".png');"
    + "background-size: contain;"
    + "background-repeat: no-repeat;"
    + "background-attachment: fixed;"
    + "background-position: center;"
    + "font-family: Open Sans;"
    + "font-weight: 600;"
    + "height: 100vh;"


if (!process.server) {
    let show = false;
    const toggle = (e: { ctrlKey: boolean }) => {
        show = !show;
        if (!e.ctrlKey) show = false;
        const el = document.getElementById("asdf")!;
        el.style.background = !show ? "black" : "";
        el.style.opacity = show ? "0.6" : "1";
    }
    document.onmousedown = toggle
    //document.onmouseup = toggle
    toggle({ ctrlKey: false });
}

</script>

<template>
    <div class="w-full h-full" :style="style">
        <div id="asdf" class="m-auto max-w-sm h-full flex flex-col items-center p-3" style="backdrop-filter: blur(1px);">
            <NuxtPage />
        </div>
    </div>
</template>
