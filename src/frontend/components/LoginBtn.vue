<script lang="ts" setup>
import { Effect } from "effect";

const actor = useActor();
const largeFont = useLargeFont();

const logout = () => {
  Effect.runPromise(logoutActor()).then(() => {
    navigateTo("/");
  });
};
</script>

<template>
  <NuxtLink to="/login" class="btn" :class="{ 'text-xl': largeFont }" v-if="!actor">
    Login
    <Icon name="material-symbols:login" />
  </NuxtLink>
  <button class="btn" :class="{ 'text-xl': largeFont }" v-else @click="logout">
    Logout
    <Icon name="material-symbols:logout" />
  </button>
</template>
