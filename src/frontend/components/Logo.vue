<script lang="ts" setup>

const props = defineProps<{
    logo: string,
    size?: string,
}>();

let allkinds = !props.logo || props.logo === "allkinds";

let url: string | null = null;
let icon: string | null = null;

if (allkinds) {
    icon = "gg:shape-hexagon";
} else if (props.logo.startsWith("http")) {
    url = props.logo;
} else if (props.logo.startsWith("data:")) {
    url = props.logo;
} else {
    icon = props.logo
}

</script>
<template>
    <div>
        <Icon v-if="icon" :name="icon" :size="props.size || '1.4em'" style="margin-top: -6px;" />
    </div>
</template>
