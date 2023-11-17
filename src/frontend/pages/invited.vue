<!--
Landing page
-->
<script lang="ts" setup>
import { Effect } from "effect";

definePageMeta({ title: "Allkinds.Teams" });

const team = useState(
    'invitedbyteam',
    () => { return { "name": "Spotify.Amsterdam", "logo": "https://1000logos.net/wp-content/uploads/2017/08/Spotify-Logo.png" } }
);

async function login(provider: Provider) {
    if (await Effect.runPromise(checkAuth(provider))) {
        console.log("already logged in");
        navigateTo("/welcome");
    }
}

</script>

<template>
    <header class="text-3xl p-4 text-center">
        <AllkindsTitle>Allkinds.Teams</AllkindsTitle>

        <div class="max-w-60 my-10">Find friends among your colleagues</div>
    </header>

    <div class="text-center">
        <div>You were invited by: </div>
        <div class="text-xl m-4">{{ team.name }}</div>
        <img :src="team.logo" alt="logo" class="h-32 inline-block">
    </div>

    <div class="grow flex flex-col items-center">
        <Btn class="w-72 mt-32" @click="login('II')">
            Log in with Internet&nbsp;Identity
        </Btn>
    </div>

    <footer class="text-center w-full m-2">
        <span class="text-xs">
            Powered by
            <a href="https://internetcomputer.org/">
                InternetComputer <img src="/icp.png" class="h-5 inline" />
            </a>
        </span>
    </footer>
</template>
