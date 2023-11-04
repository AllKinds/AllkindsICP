<script lang="ts" setup>
import { useAppState } from "~/composables/appState";
import { formatError } from "../helper/errors";
import { ResultUser, User } from "~~/src/declarations/backend/backend.did";

definePageMeta({ middleware: ["auth"] });
const app = useAppState();
const backend = useActor();

if (backend.value)
  backend.value
    .getUser()
    .then((u) => (app.value.user = u.ok))
    .then(() => console.log("appState set to", app.value));

function showInfo(i: AppState) {
  console.log("i is", i);
  const user = i.user;
  return user?.username + ": " + user?.points + " points";
}
</script>

<template>
  <TextBlock>
    <h1>Welcome</h1>
    <p></p>
  </TextBlock>

  {{ showInfo(app) }}

  <Btn to="/home">continue</Btn>
</template>
