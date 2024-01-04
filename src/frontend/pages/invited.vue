<!--
Landing page
-->
<script lang="ts" setup>
import { Effect } from 'effect';

definePageMeta({
    title: "Confirm invite",
    layout: 'default'
});

const app = useAppState();

async function login(provider: Provider) {
    if (await Effect.runPromise(checkAuth(provider))) {
        console.log("already logged in");
        navigateTo("/welcome");
    }
}
const invite = useState("invite-code", () => "");

if (inBrowser()) {
    const ref = document.location.hash
    try {
        const team = ref.split(":")[0].replace(/[^a-z]/g, "");
        const code = ref.split(":")[1];
        if (team.length < 2) throw "";
        invite.value = code;
        app.loadTeams(0, team);
        // TODO: auto select team if it exists
    } catch {
        app.loadTeams(0)
    }
}

if (inBrowser()) {
    app.getTeam();
    app.loadTeams(0);

}

</script>

<template>
    <div class="w-full flex-grow flex flex-col items-center">
        <AllkindsTitle>
            Allkinds.Teams
        </AllkindsTitle>

        <h1>
            Find friends among your colleagues
        </h1>

        <div class="grow flex flex-col items-center">
            <div>You were invited by:</div>

            <h1>
                {{ app.getTeam()?.info.name }}
            </h1>
            <img :src="toDataUrl(app.getTeam()?.info.logo || [])" height="150" width="150" class="m-auto rounded-2xl" />
        </div>

        <Btn class="w-80 mt-2" @click="login('II')">
            Join with Internet&nbsp;Identity
        </Btn>

        <ICFooter />
    </div>
</template>
