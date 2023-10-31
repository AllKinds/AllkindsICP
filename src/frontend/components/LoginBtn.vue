<script lang="ts" setup>
import { backend } from "~~/src/declarations/backend";

const actor = useState<typeof backend | null>("actor", () => null);
const largeFont = await useState("largeFont", () => false);
</script>

<template>
  <NuxtLink to="/login" class="btn" :class="{ 'text-xl': largeFont }" v-if="!actor">
    Login
    <Icon name="material-symbols:login" />
  </NuxtLink>
  <button class="btn" :class="{ 'text-xl': largeFont }" v-else @click="logoutActor">
    Logout
    <Icon name="material-symbols:logout" />
  </button>
</template>
