<script lang="ts" setup>
if (inBrowser()) console.log("loading", document.location.href);
definePageMeta({
    title: "Invited",
    layout: 'default'
});
 
const app = useAppState();
const auth = useAuthState();
const route = useRoute();
const invite = useState<string>("invite-code", () => "");
const invitedBy = ref<string|undefined>(undefined);
var inviteSet = false;
var team: string;

async function login(provider: Provider) {
    storeInvite();
    await loginTest(provider).then(
        (res) => {
            if (res.ok) {
                auth.setClient(!!res.val);
                navTo("/logged-in");
            } else {
                addNotification("error", "Login failed\n" + res.err)
            }
        },
        (e) => addNotification("error", "Login failed\n" + e)
    );

    console.log("logged in");
    app.loadUser(0, false);
    navTo("/logged-in");
}

const storeInvite = () => {
    window.localStorage.setItem("invite", JSON.stringify({
        team: team,
        invite: invite.value,
        invitedBy: invitedBy.value,
    }));
}

const join = () => {
    if (!auth.loggedIn) {
        console.log("Not logged in, start login")
        login('II')
    } else if (app.user.status === 'ok') {
        storeInvite();
        navTo("/verify-invite");
    } else {
        storeInvite();
        navTo("/logged-in");
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
        const b = params.get("by");
        if (b !== null) {
            invitedBy.value = b;
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
    if (!userLoaded && auth.loggedIn) {
        app.loadUser(0, false);
        userLoaded = true;
    }
    return app.getTeam(false)?.permissions.isMember
}

</script>

<template>
    <div class="w-full flex-grow flex flex-col items-center">
        <AllkindsTitle class="py-16" />

        <div class="grow" />

        <h1>
            Discover meaningful connections within
        </h1>

        <div class="grow" />

        <NetworkDataContainer :networkdata="app.getTeams()">
            <div v-if="app.getTeam(false)" class=" flex flex-col items-center">
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
        <Btn v-if="!auth.loggedIn" class="w-80 mt-2" @click="join()" :disabled="invite === ''">
            Join with Internet&nbsp;Identity
        </Btn>
        <Btn v-else-if="isMember()" class="w-80 mt-2" to="/team-info">
            Goto team
        </Btn>
        <Btn v-else-if="app.getUser().status === 'ok'" class="w-80 mt-2" @click="join()" :disabled="invite === ''">
            Join the team as {{ app.getUser().data?.user.displayName }}
        </Btn>
        <Btn v-else class="w-80 mt-2" @click="join()" :disabled="invite === ''">
            Join the team
        </Btn>

        <div class="grow" />

        <ICFooter />
    </div>
</template>
