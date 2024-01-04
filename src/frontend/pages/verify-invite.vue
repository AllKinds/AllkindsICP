<script lang="ts" setup>

definePageMeta({
    title: "Join a team",
    layout: 'default'
});

const app = useAppState();

let team: string | undefined;
let invite: string | undefined;

let isValid = useState("verify-valid");
isValid.value = false;

let isInvalid = useState("verify-invalid");
isInvalid.value = false;

let hasInvite = useState("verify-has-invite");
hasInvite.value = true;

const loading = () => {
    return hasInvite.value && !isInvalid.value && !isValid.value && !isMember();
}

let userLoaded = false;
const isMember = () => {
    if (!userLoaded && isLoggedIn()) {
        app.loadUser(0, false);
        userLoaded = true;
    }
    return app.getTeam(false)?.permissions.isMember
}

if (inBrowser()) {
    try {
        const obj: { team: string, invite: string } = JSON.parse(window.localStorage.getItem("invite") || "");
        team = obj.team;
        invite = obj.invite;
    } catch (e) {
        window.localStorage.removeItem("invite");
    }

    if (isMember()) {
        // already joined
    } else if ((team !== undefined) && (invite !== undefined)) {
        app.setTeam(team);
        app.joinTeam(invite).then(() => {
            app.loadTeams(0);
            navigateTo("/team-info")
        }, () => {
            // TODO: set verificationFailed on network error
            isInvalid.value = true;
        });
    } else {
        hasInvite.value = false;
    }
    app.loadTeams(0);
}

const getTeam = () => app.getTeam(false);


</script>

<template>
    <div class="w-full flex-grow flex flex-col items-center">
        <AllkindsTitle link-to="/select-team"></AllkindsTitle>

        <h1>Verifying invite</h1>
        <div class="grow" />

        <NetworkDataContainer :networkdata="app.getTeams()" class="w-full flex-grow flex flex-col">

            <img :src="toDataUrl(getTeam()?.info.logo || [])" height="150" width="150" class="m-auto rounded-2xl" />

            <div class="w-full text-center mt-4 mb-8 text-lg">
                Verifying invite for <span class="font-bold">{{ getTeam()?.info.name }} ({{ app.team }})</span>
            </div>

            <div class="p-4 rounded-lg my-2 w-full">
                <p>
                    {{ getTeam()?.info.about }}
                </p>
            </div>

            <div class="w-2 flex-grow"></div>
        </NetworkDataContainer>

        <Icon v-if="loading()" name="line-md:loading-alt-loop" size="3em" />

        <div v-if="isValid"> Invite is valid. You successfully joined the team! </div>
        <div v-if="isInvalid"> Invite is invalid. </div>
        <div v-if="!hasInvite"> Invite was not set. </div>
        <div v-if="isMember()"> You are already a member of this team. </div>

        <div class="grow" />

        <Btn v-if="isValid" to="/team-info">Next</Btn>
        <Btn v-if="isInvalid && team" :to="'/team/' + team" class="w-72">Retry with another code</Btn>
        <Btn v-if="isInvalid" to="/select-team" class="w-72">Select another team</Btn>
        <Btn v-if="!hasInvite" to="/select-team">Select a team</Btn>
        <Btn v-if="isMember()" to="/team-info">Goto team</Btn>

        <div class="grow" />
    </div>
</template>
