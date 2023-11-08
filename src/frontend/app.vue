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
watch(app, () => console.log("appState changed to", app.value));

</script>

<template>
    <div class="w-full">
        <div class="max-w-4xl mx-auto h-screen flex flex-col">
            <nav class="flex justify-between">
                <FontSizeBtn />
                <AllkindsTitle v-if="route.meta.title">{{ route.meta.title }}</AllkindsTitle>
                <LoginBtn />
            </nav>

            <div class="grow flex flex-col items-center pb-3">
                <NuxtPage />
            </div>
        </div>
    </div>
</template>
