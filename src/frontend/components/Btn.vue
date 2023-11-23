<script lang="ts" setup>
const props = defineProps({
    to: String,
    width: String,
    outline: String,
    disabled: String,
});

const largeFont = useLargeFont();
const outline = (props.outline || '');
const width = (props.width || 'w-48');
const disabled = (props.disabled?.startsWith('t') ? 'btn-disabled' : '')
</script>

<template>
    <NuxtLink :to="to" :class="width + ' ' + outline + ' ' + disabled"
        class="m-3 p-4 border rounded-full text-center cursor-pointer active:scale-95 transition-all hover:bg-white hover:text-black">
        <span :class="{ 'text-xl': largeFont }">
            <slot />
        </span>
    </NuxtLink>
</template>
