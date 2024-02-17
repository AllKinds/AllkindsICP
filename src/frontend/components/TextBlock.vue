<script lang="ts" setup>
defineProps<{
    align?: "text-left" | "text-justify" | "text-center" | "text-right"
}>();
</script>

<template>
    <div class="max-w-lg prose py-8 px-4 text-xl" :class="[align || 'text-left']">
        <slot />
    </div>
</template>
