<script lang="ts" setup>
const props = defineProps({
  to: String,
  width: String,
  outline: String,
});

const largeFont = useState("largeFont", () => false);
</script>

<template>
  <NuxtLink
    :to="to"
    class="m-3 btn rounded-full"
    :class="props.width || 'w-48' + ' ' + (props.outline || 'btn-outline')"
  >
    <span :class="{ 'text-xl': largeFont }"> <slot /> </span>
  </NuxtLink>
</template>
