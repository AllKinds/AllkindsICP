<!--
Landing page
-->
<script lang="ts" setup>
import { Effect } from 'effect';

definePageMeta({
    title: "Invited",
    layout: 'default'
});


const app = useAppState();
const route = useRoute();

async function login(provider: Provider) {
    await runNotify(checkAuth(provider));
    if (!isLoggedIn()) {
        addNotification("error", "Login failed")
        return;
    }

    console.log("logged in");

    navigateTo("/welcome");
}
const invite = useState("invite-code", () => "");

if (inBrowser()) {
    let params = new URLSearchParams(document.location.search);
    try {
        const team = route.params.team + "";
        const code = params.get("invite");
        if (code === null) {
            addNotification("error", "No invite code set");
        } else {
            invite.value = code;
            app.setTeam(route.params.team + "");
            app.getTeam(false);
            app.loadTeams(0, team);
        }
    } catch {
        app.loadTeams(0)
    }
}

</script>

<template>
    <div class="w-full flex-grow flex flex-col items-center">
        <AllkindsTitle>
            Allkinds.Teams
        </AllkindsTitle>

        <div class="grow" />

        <h1>
            Find friends among your colleagues
        </h1>

        <div class="grow" />

        <NetworkDataContainer :networkdata="app.getTeams()">
            <div v-if="app.getTeam(false)" class=" flex flex-col items-center">
                <div>You were invited by:</div>
                <h1>
                    {{ app.getTeam(false)?.info.name }}
                </h1>
                <img :src="toDataUrl(app.getTeam(false)?.info.logo || [], 'team', app.team)" height="150" width="150"
                    class="m-auto rounded-2xl" />
            </div>
        </NetworkDataContainer>

        <div class="grow" />

        <Btn v-if="isLoggedIn()" class="w-80 mt-2" @click="login('II')">
            Join the team
        </Btn>
        <Btn v-else class="w-80 mt-2" @click="login('II')">
            Join with Internet&nbsp;Identity
        </Btn>


        <div class="grow" />

        <ICFooter />
    </div>
</template>
