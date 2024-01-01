<script lang="ts" setup>
definePageMeta({
    title: "Color reference",
    layout: 'default'
});
const colors = [
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

const icons = [
    "ph:plus-circle",
    "ph:minus-circle",
    "gg:shape-hexagon",
    "line-md:loading-alt-loop",
    "material-symbols:arrow-forward-ios",
    "prime:users",
    "tabler:checkbox",
    "ci:checkbox-unchecked",
    "ph:gear",
    "tabler:user-shield",
    "tabler:user-check",
    "tabler:trash",
    "charm:refresh",
    "tabler:info-hexagon",
    "prime:user-plus",
    "prime:user-minus",
];

const themes = ["default", "dark", "light", "allkinds", "black"];
</script>
<template>
    <div class="w-full flex-grow">
        <div class="flex">
            <div v-for="theme in themes" :data-theme="theme">
                <button class="m-4 btn btn-outline" :data-set-theme="theme">Use {{ theme }}</button>
                <div v-for="color in colors" class="w-52 h-10" :class="color">{{ color }}</div>
            </div>
        </div>

        <div class="flex flex-row flex-wrap" style="width: 800px">
            <div v-for="icon in icons" class="text-center p-5">
                <Icon :name="icon" size="3em" />
                <div>
                    {{ icon }}
                </div>
            </div>
        </div>
    </div>
</template>
