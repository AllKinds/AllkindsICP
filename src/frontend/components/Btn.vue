<script lang="ts" setup>
defineProps({
  to: String,
  class: String,
});
const largeFont = useState("largeFont", () => false);
</script>

<template>
  <NuxtLink :to="to" class="m-3 btn btn-outline rounded-full w-48" :class="class">
    <span :class="{ 'text-xl': largeFont }"> <slot /> </span>
  </NuxtLink>
</template>
