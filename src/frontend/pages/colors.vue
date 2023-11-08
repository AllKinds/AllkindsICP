<script lang="ts" setup>
definePageMeta({ title: "Color reference" });
const colors = [
    "",
    "bg-primary",
    "bg-secondary",
    "bg-accent",
    "bg-neutral",
    "bg-info",
    "bg-success",
    "bg-warning",
    "bg-warning-content",
    "bg-error",
];

const themes = ["default", "dark", "light", "allkinds", "black"];
</script>
<template>
    <div class="flex">
        <div v-for="theme in themes" :data-theme="theme">
            <button class="m-4 btn btn-outline" :data-set-theme="theme">Use {{ theme }}</button>
            <div v-for="color in colors" class="w-52 h-10" :class="color">{{ color }}</div>
        </div>
    </div>
</template>
