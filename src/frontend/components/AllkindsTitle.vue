<script lang="ts" setup>
const largeFont = useLargeFont();
const props = defineProps<{
    logo?: string,
    linkTo?: string,
}>();

</script>
<template>
    <div class="font-bold flex justify-left w-full pt-4 pb-3" :class="{ 'text-xl': largeFont }">
        <NuxtLink :to="props.linkTo">
            <Logo :logo="props.logo || 'allkinds'" class="ml-3" size="2em" />&nbsp;
        </NuxtLink>
        <slot />
    </div>
</template>
