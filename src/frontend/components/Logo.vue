<script lang="ts" setup>

const props = defineProps<{
    logo: string,
}>();

let allkinds = !props.logo || props.logo === "allkinds";

let url: string | null = null;
let icon: string | null = null;

if (allkinds) {
    icon = "gg:shape-hexagon";
} else if (props.logo.startsWith("http")) {
    url = props.logo;
} else {
    icon = props.logo
}

</script>
<template>
    <div>
        <span v-if="allkinds && false" style="
            letter-spacing: -2px;
            font-size: 0.65em;
            margin-right: 0.3em;
            margin-bottom: 0.3em;
        ">⬤⬤</span>

        <Icon v-if="icon" :name="icon" size="1.4em" style="margin-top: -6px;" />

        <img v-if="url" :src="url" alt="logo" />
    </div>
</template>
