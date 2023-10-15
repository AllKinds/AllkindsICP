<script lang="ts" setup>
import { createActor } from "../../declarations/backend";
import { AuthClient } from "@dfinity/auth-client";
import { HttpAgent, Agent } from "@dfinity/agent";

const counter = useState("counter", () => Math.round(Math.random() * 1000));

let actor = null;

async function login() {
  // create an auth client
  let authClient = await AuthClient.create();

  // start the login process and wait for it to finish
  await new Promise((resolve) => {
    console.error("runtimeConfig: " + JSON.stringify(useRuntimeConfig()));
    authClient.login({
      identityProvider: process.env.II_URL,
      onSuccess: () => resolve(null),
    });
  });

  // At this point we're authenticated, and we can get the identity from the auth client:
  const identity = authClient.getIdentity();
  // Using the identity obtained from the auth client, we can create an agent to interact with the IC.
  const agent = new HttpAgent({ identity });
  // Using the interface description of our webapp, we create an actor that we use to call the service methods.
  actor = createActor(process.env.BACKEND_CANISTER_ID!, {
    agent,
  });
}
</script>

<template>
  <div class="grow flex flex-col items-center">
    Counter: {{ counter }}
    <button @click="counter++">+</button>
    <button @click="counter--">-</button>

    <button class="btn btn-outline w-72 m-3 rounded-full" @click="login">
      Log in with Internet Identity
    </button>
    <a href="#" class="btn btn-outline w-72 m-3 rounded-full"> Log in with email </a>
    <NuxtLink to="/" class="m-3 link">cancel</NuxtLink>
  </div>
</template>
