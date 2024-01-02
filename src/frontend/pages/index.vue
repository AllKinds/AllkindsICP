<!--
Landing page
-->
<script lang="ts" setup>
import { Effect } from "effect";

definePageMeta({
    title: "Login",
    layout: 'default'
});

async function login(provider: Provider) {
    if (await Effect.runPromise(checkAuth(provider))) {
        console.log("already logged in");
        navigateTo("/welcome");
    }
}
</script>

<template>
    <div class="w-full flex-grow flex flex-col items-center">
        <AllkindsTitle>Allkinds.Teams</AllkindsTitle>

        <div class="text-2xl p-4 text-center">
            <div class="max-w-60 my-24 font-bold">
                Make your team stronger <br> and your employees <br> happier.
            </div>
        </div>


        <div class="grow flex flex-col items-center">
        </div>

        <Btn to="/about" class="w-80"> Learn more </Btn>

        <Btn class="w-80 mt-2" @click="login('II')">
            Join with Internet&nbsp;Identity
        </Btn>

        <ICFooter />
    </div>
</template>
