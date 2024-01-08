<!--
Landing page
-->
<script lang="ts" setup>
import { Effect } from "effect";
if (inBrowser()) console.log("loading", document.location.href);

definePageMeta({
    title: "Login",
    layout: 'default'
});

const teamSelected = () => window.localStorage.getItem("team") && !window.localStorage.getItem("invite");
const hasInvite = () => window.localStorage.getItem("invite");

async function login(provider: Provider) {
    if (!inBrowser()) return;
    if (await Effect.runPromise(checkAuth(provider))) {
        console.log("logged in");
        if (hasInvite()) {
            navigateTo("/welcome")
        } else {
            navigateTo("/team-info");
        }
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

        <Btn v-if="isLoggedIn() && teamSelected()" class="w-80 mt-2" @click="login('II')">
            Welcome back
        </Btn>
        <Btn v-else-if="isLoggedIn()" class="w-80 mt-2" to="/select-team">
            Select a team
        </Btn>
        <Btn v-else class="w-80 mt-2" @click="login('II')">
            Join with Internet&nbsp;Identity
        </Btn>

        <ICFooter />
    </div>
</template>
