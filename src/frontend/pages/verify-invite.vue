<script lang="ts" setup>


definePageMeta({
    title: "Join a team",
    layout: 'default'
});

const app = useAppState();
const auth = useAuthState();

let team: string | undefined = undefined;
let invite: string | undefined = undefined;
let invitedBy: string | null = null;

let isValid = ref(false);

let isInvalid = ref<null | string>(null);

let hasInvite = ref(true);

const loading = () => {
    return hasInvite.value && !isInvalid.value && !isValid.value && !isMember();
}

let userLoaded = false;
const isMember = () => {
    if (!userLoaded && auth.loggedIn) {
        app.loadUser(0, false);
        userLoaded = true;
    }
    return app.getTeam(false)?.permissions.isMember
}

const clearInvite = () => {
    window.localStorage.removeItem("invite");
}

const getTeam = () => app.getTeam(false);

if (inBrowser()) {
    try {
        const obj: { team: string, invite: string, invitedBy: string | undefined } = JSON.parse(window.localStorage.getItem("invite") || "");
        team = obj.team;
        invite = obj.invite;
        invitedBy = obj.invitedBy || null;
    } catch (e) {
        console.warn("Failed to parse invite:", e);
        clearInvite();
    }

    if (isMember()) {
        // already joined
        clearInvite();
    } else if ((team !== undefined) && (invite !== undefined)) {
        app.setTeam(team);
        app.joinTeam(invite, invitedBy).then(() => {
            app.loadTeams(0);
            clearInvite();
            navTo("/team-info");
        }, () => {
            // TODO: set verificationFailed on network error
            isInvalid.value = invite ?? null;
            clearInvite();
        });
    } else {
        hasInvite.value = false;
        clearInvite();
    }
    app.loadTeams(0);
}

</script>

<template>
    <div class="w-full flex-grow flex flex-col items-center">
        <AllkindsTitle link-to="/select-team" @click="clearInvite()"><span /></AllkindsTitle>

        <h1>Verifying invite</h1>
        <div class="grow" />

        <NetworkDataContainer v-if="hasInvite" :networkdata="app.getTeams()" class="w-full grow flex flex-col">

            <img :src="toDataUrl(getTeam()?.info.logo || [])" height="150" width="150" class="m-auto rounded-2xl" />

            <div class="w-full text-center mt-4 mb-8 text-lg">
                Verifying invite for <span class="font-bold">{{ getTeam()?.info.name }} ({{ team }})</span>
            </div>

            <div class="p-4 rounded-lg my-2 w-full">
                <p>
                    {{ getTeam()?.info.about }}
                </p>
            </div>

            <div class="w-2 flex-grow"></div>
        </NetworkDataContainer>
        <div v-else class="grow">
            <img :src="toDataUrl(getTeam()?.info.logo || [])" height="150" width="150" class="m-auto rounded-2xl" />
        </div>

        <Icon v-if="loading()" name="line-md:loading-alt-loop" size="3em" />

        <div v-if="isValid"> Invite is valid. You successfully joined the team! </div>
        <div v-if="isInvalid !== null"> Invite is invalid. (invite code: '{{ isInvalid }}' {{ invitedBy }}) </div>
        <div v-if="!hasInvite"> Invite was not set. </div>
        <div v-if="isMember()"> You are already a member of this team. </div>

        <div class="grow" />

        <Btn v-if="isValid" @click="clearInvite()" to="/team-info" class="w-72">Next</Btn>
        <Btn v-if="isInvalid && team" @click="clearInvite()" :to="'/join/' + team" class="w-72">Retry with another code
        </Btn>
        <Btn v-if="isInvalid" @click="clearInvite()" to="/select-team" class="w-72">Select another team</Btn>
        <Btn v-if="isMember()" @click="clearInvite()" to="/team-info" class="w-72">Goto team</Btn>

        <div class="grow" />
    </div>
</template>
