<script lang="ts" setup>
const props = defineProps<{
    logo: string,
    size?: string
}>();

const icon = getIcon(props.logo);

</script>

<template>
    <Icon :name="icon.icon" :size="props.size ?? '1.4em'" />
</template>
