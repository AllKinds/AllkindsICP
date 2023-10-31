<script lang="ts" setup>
const largeFont = useState("largeFont", () => false);
defineProps({ align: String });
</script>

<template>
  <div
    class="max-w-xl prose p-8"
    :class="[{ 'text-xl': largeFont }, align || 'text-justify']"
  >
    <slot />
  </div>
</template>
