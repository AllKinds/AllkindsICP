<script lang="ts" setup>
definePageMeta({
    title: "Color reference",
    layout: 'default'
});

import { colors } from '~/utils/color';

const css = (c: Color) => {
    return "." + c.color + " {\n  background-color: " + c.bg + ";\n  color: " + c.fg + ";\n  border-color: " + c.fg + "\n}" +
        "\n" +
        "." + c.color + " .btn:hover {\n  background-color: " + c.fg + ";\n  color: " + c.fgBtn + "\n}" +
        "\n\n"
}

const icons = [
    "ph:plus-circle",
    "ph:minus-circle",
    "gg:shape-hexagon",
    "mdi:hexagon-outline",
    "tabler:info-hexagon",
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
    "prime:user-plus",
    "prime:user-minus",
    "mynaui:layers-three",
];

const themes = ["black", "light"];
</script>
<template>
    <div class="w-92 flex-grow">
        <div class="flex flex-row flex-wrap">
            <div v-for="color, name in colors" :class="color.color" class="w-32 text-center p-2">
                <button :class="color.color" class="m-2 btn btn-outline">{{ name }}</button>
                <br />
                {{ name }}
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

        <pre>
/* generated css */
<span v-for="color, name in colors">{{ css(color) }}</span>
        </pre>
    </div>
</template>
