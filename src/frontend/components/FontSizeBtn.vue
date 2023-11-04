<script lang="ts" setup>
const largeFont = useLargeFont();
</script>

<template>
  <button class="btn items-baseline" @click="largeFont = !largeFont">
    <span class="text-xl" :class="{ underline: !largeFont }">a</span
    ><span class="text-4xl font-normal" :class="{ underline: largeFont }">a</span>
  </button>
</template>
