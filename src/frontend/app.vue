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

const app = useAppState();

const style = () =>
    "font-family: Open Sans; sans;"
    + "font-weight: 600;"
    + "height: 100vh;";


if (inBrowser()) {
    if (isLoggedIn()) {
        console.log("load user data")
        app.loadUser(undefined, false);
    }
}

</script>

<template>
    <div class="w-full h-full transition-all" :style="style()">
        <div class="m-auto max-w-lg h-full flex flex-col items-center p-3">
            <NuxtPage />
        </div>
    </div>
</template>
