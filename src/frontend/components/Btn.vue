<script lang="ts" setup>
import { boolean } from 'effect/dist/declarations/src/Equivalence';

const props = defineProps<{
    to?: string,
    width?: string,
    outline?: string,
    disabled?: boolean,
}>();

const largeFont = useLargeFont();
const outline = () => (props.outline || '');
const width = () => (props.width || 'w-48');
</script>

<template>
    <NuxtLink :to="to" :class="[width(), outline(), props.disabled ? 'pointer-events-none opacity-50' : '']"
        class="m-3 p-4 border rounded-full text-center cursor-pointer active:scale-95 transition-all hover:bg-white hover:text-black">
        <span :class="{ 'text-xl': largeFont }">
            <slot />
        </span>
    </NuxtLink>
</template>
