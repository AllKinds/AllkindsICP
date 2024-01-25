<script lang="ts" setup>
const largeFont = useLargeFont();
const props = defineProps<{
    logo?: string,
    linkTo?: string,
    logoUrl?: string,
}>();

const icon = props.logo ?? getIcon(props.linkTo ?? "").icon;

</script>
<template>
    <div class="font-bold flex flex-row items-baseline w-full py-4" :class="{ 'text-xl': largeFont }">
        <NuxtLink :to="props.linkTo" class="flex">
            <img v-if="props.logoUrl" :src="props.logoUrl" width="32" class="rounded-md" style="margin-top: -6px;" />&nbsp;
            <Icon v-else :name="icon" size="2em" style="margin-top: -6px;" />
        </NuxtLink>

        <div class="flex-grow px-3 text-center">
            <slot />
        </div>
        <slot name="action">
            <div style="width: 1em; height: 1em;" />
        </slot>
    </div>
</template>
