<script lang="ts" setup>
definePageMeta({ middleware: ["auth"] });
</script>

<template>
  <h1>Welcome</h1>
  <Btn to="/register">continue</Btn>
</template>
