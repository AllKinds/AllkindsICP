<script lang="ts" setup>
const largeFont = useLargeFont();
const props = defineProps<{
    logo?: string,
    linkTo?: string,
}>();

</script>
<template>
    <div class="font-bold flex flex-row items-baseline w-full py-4" :class="{ 'text-xl': largeFont }">
        <NuxtLink :to="props.linkTo" class="flex">
            <Logo :logo="props.logo || 'allkinds'" size="2em" />&nbsp;
        </NuxtLink>

        <div class="flex-grow px-3 text-center">
            <slot />
        </div>
        <slot name="action">
            <div style="width: 1em; height: 1em;" />
        </slot>
    </div>
</template>
