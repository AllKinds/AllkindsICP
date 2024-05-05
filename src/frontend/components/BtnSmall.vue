<script lang="ts" setup>

const props = defineProps<{
    to?: string,
    width?: string,
    outline?: string,
    disabled?: boolean,
    loading?: boolean,
}>();

const outline = () => (props.outline || '');
const width = () => (props.width || 'w-32');
</script>

<template>
    <NuxtLink :to="to" :class="[width(), outline(), props.disabled ? 'pointer-events-none opacity-50' : '']"
        class="my-6 p-1 border-2 rounded-full text-center cursor-pointer active:scale-95 transition-all hover:bg-white hover:text-black inline-block">
        <Icon name="line-md:loading-alt-loop" v-if="props.loading" class="text-s text-center w-full" />
        <span class="">
            <slot />
        </span>
    </NuxtLink>
</template>
