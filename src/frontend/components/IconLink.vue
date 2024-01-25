<script lang="ts" setup>
const props = defineProps({
    to: String,
});

const icon = getIcon(props.to ?? "");

</script>

<template>
    <NuxtLink :to="props.to">
        <Icon :name="icon.icon" size="2em" />
    </NuxtLink>
</template>