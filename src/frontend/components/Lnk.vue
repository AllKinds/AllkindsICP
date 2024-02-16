<script lang="ts" setup>
const props = defineProps({
    to: String,
    width: String,
    outline: String,
    disabled: String,
});

const outline = (props.outline || 'btn-outline');
const width = (props.width || '');
const disabled = (props.disabled?.startsWith('t') ? 'btn-disabled' : '')
</script>

<template>
    <NuxtLink :to="to" class="px-4 py-2 rounded-full link underline" :class="width + ' ' + outline + ' ' + disabled">
        <span class="text-xl">
            <slot />
        </span>
    </NuxtLink>
</template>
