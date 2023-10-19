<script lang="ts" setup>
definePageMeta({ middleware: ["auth"] });
</script>

<template>
  <h1>Welcome</h1>
  <NuxtLink to="/" class="m-3 link">back</NuxtLink>
</template>
