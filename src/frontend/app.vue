<script lang="ts" setup>
import { themeChange } from "theme-change";
import 'vue3-toastify/dist/index.css';

const app = useAppState();
const auth = useAuthState();

onMounted(() => {
    themeChange(false);
});

onNuxtReady(() => {
    auth.check();
});


const style = () =>
    "font-family: Open Sans; sans;"
    + "font-weight: 600;"
    + "height: 100vh;";


if (inBrowser()) {
    if (auth.loggedIn) {
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


<style>
@import url("~/public/app.css");

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
</style>