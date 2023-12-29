<!--
Page to select login provider and initiate login process
-->

<script lang="ts" setup>
import { Effect } from "effect";

definePageMeta({ title: "Log in" });

async function login(provider: Provider) {
    if (await Effect.runPromise(checkAuth(provider))) {
        console.log("already logged in");
        navigateTo("/welcome");
    }
}

if (await Effect.runPromise(checkAuth(null)).catch((e) => false)) {
    console.warn("navigated to /login, but already logged in");
    navigateTo("/welcome");
}


</script>

<template>
    <div class="grow flex flex-col items-center">
        <TextBlock class="max-w-sm text-center" align="text-center">
            <p>
                Allkinds is powered by the Internet Computer.<br />
                It’s fully decentralised and secured. <br />
                <img src="/icp.png" class="w-20 inline" />
            </p>
        </TextBlock>

        <div class="w-full flex-grow"></div>

        <Btn class="w-72" @click="login('II')">
            Log in with Internet&nbsp;Identity
        </Btn>
        <Lnk to="/"> Cancel </Lnk>
    </div>
</template>
