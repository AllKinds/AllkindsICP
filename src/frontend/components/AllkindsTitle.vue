<script lang="ts" setup>
const largeFont = useLargeFont();
const props = defineProps<{
    logo?: string,
}>();

</script>
<template>
    <NuxtLink to="/" class="font-bold flex justify-left w-full pt-4" :class="{ 'text-xl': largeFont }">
        <Logo :logo="props.logo || 'allkinds'" class="ml-8" />&nbsp;
        <slot />
    </NuxtLink>
</template>
