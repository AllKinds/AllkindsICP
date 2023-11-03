<script lang="ts" setup>
import { formatError } from "../helper/backend";
import { ResultUser } from "~~/src/declarations/backend/backend.did";

const dummyResult: ResultUser = { err: { notLoggedIn: null } };

definePageMeta({ middleware: ["auth"] });
const info = useState<ResultUser>("userInfo", () => dummyResult);
const backend = useActor();

if (backend.value)
  backend.value
    .getUser()
    .then((u) => (info.value = u))
    .then(() => console.log("info set to", info.value));

function showInfo(i: ResultUser) {
  if (!i) {
    console.log("i is", i);
    return "never";
  }
  if ("err" in i) {
    return formatError(i.err);
  } else {
    const user = i.ok;
    return user.username + ": " + user.points + " points";
  }
}
</script>

<template>
  <TextBlock>
    <h1>Welcome</h1>
    <p></p>
  </TextBlock>

  {{ showInfo(info) }}

  <Btn to="/register">continue</Btn>
</template>
