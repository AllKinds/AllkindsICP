<script lang="ts" setup>
const largeFont = useLargeFont();
</script>
<template>
  <NuxtLink
    to="/"
    class="font-bold flex justify-center items-center"
    :class="{ 'text-xl': largeFont }"
  >
    <span
      style="
        letter-spacing: -2px;
        font-size: 0.65em;
        margin-right: 0.3em;
        margin-bottom: 0.3em;
      "
      >⬤⬤</span
    >

    <slot />
  </NuxtLink>
</template>
