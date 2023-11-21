<script lang="ts" setup>
const largeFont = useState("largeFont", () => true);
defineProps<{ align?: "text-left" | "text-justify" | "text-center" | "text-right" }>();
</script>

<template>
    <div class="max-w-lg prose py-8 px-4" :class="[{ 'text-xl': largeFont }, align || 'text-left']">
        <slot />
    </div>
</template>
