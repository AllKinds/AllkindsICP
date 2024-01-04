<script lang="ts" setup>
if (inBrowser()) console.log("loading", document.location.href);
definePageMeta({
    title: "Invited",
    layout: 'default'
});


const app = useAppState();
const route = useRoute();
const invite = useState<string>("invite-code", () => "");
var inviteSet = false;
var team: string;
var code: string;

async function login(provider: Provider) {
    storeInvite();
    await runNotify(checkAuth(provider));
    if (!isLoggedIn()) {
        addNotification("error", "Login failed");
        return;
    }

    console.log("logged in");
    app.loadUser(0, false);
    navigateTo("/welcome");
}

const storeInvite = () => {
    window.localStorage.setItem("invite", JSON.stringify({
        team: team,
        invite: invite.value,
    }));
}

const join = () => {
    if (!isLoggedIn()) {
        login('II')
    } else if (app.user.status === 'ok') {
        storeInvite();
        navigateTo("/verify-invite");
    } else {
        storeInvite();
        navigateTo("/welcome");
    }
}

if (inBrowser()) {
    let params = new URLSearchParams(document.location.search);
    try {
        team = route.params.team + "";
        const c = params.get("invite");
        if (c !== null) {
            invite.value = c;
            inviteSet = true;
        }
        app.setTeam(route.params.team + "");
        app.getTeam(false);
        app.loadTeams(0, team);
    } catch {
        app.loadTeams(0);
    }

} else {
    // hide input on prerender
    inviteSet = true;
}

let userLoaded = false;
const isMember = () => {
    if (!userLoaded && isLoggedIn()) {
        app.loadUser(0, false);
        userLoaded = true;
    }
    return app.getTeam(false)?.permissions.isMember
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
            <div v-else>
                Team not found!
            </div>
        </NetworkDataContainer>

        <div class="grow" />

        <div v-if="!inviteSet && !isMember()" class="grow text-center">
            <TextInput v-model.trim="invite" @keyup.enter="join()" placeholder="invite-code" class="text-center" />
        </div>

        {{ isMember() ? "" : "" }}
        <Btn v-if="!isLoggedIn()" class="w-80 mt-2" @click="join()">
            Join with Internet&nbsp;Identity
        </Btn>
        <Btn v-else-if="isMember()" class="w-80 mt-2" to="/team-info">
            Goto team
        </Btn>
        <Btn v-else-if="app.user.status === 'ok'" class="w-80 mt-2" @click="join()">
            Join the team as {{ app.getUser().displayName }}
        </Btn>
        <Btn v-else class="w-80 mt-2" @click="join()">
            Join the team
        </Btn>

        <div class="grow" />

        <ICFooter />
    </div>
</template>
