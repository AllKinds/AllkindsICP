<script lang="ts" setup>
import { TeamUserInfo } from '~/utils/backend';

definePageMeta({
    title: "Allkinds",
    layout: 'default'
});
const app = useAppState();
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

let gotoInfo = false;

const setTeam = (t: TeamUserInfo) => {
    app.setTeam(t.key);
    if (gotoInfo) {
        navigateTo("/team-info")
    } else if (t.permissions.isMember) {
        navigateTo("/questions")
    } else {
        navigateTo("/join-team")
    }
}

</script>

<template>
    <div class="w-full flex-grow">
        <AllkindsTitle>Welcome</AllkindsTitle>
        <h1 class="text-center">
            We see the world with more meaningful connections.
        </h1>

        <NetworkDataContainer :networkdata="app.getTeams()" class="w-full text-lg text-center">
            <div class="w-full text-center mb-8">
                Available teams: {{ app.getTeams().data?.length }}
            </div>

            <Btn to="/create-team" class="w-72 mb-10">Create a new team</Btn>

            <div v-for="t in app.getTeams().data" @click="setTeam(t)"
                class="border border-white p-4 rounded-lg my-2 w-full cursor-pointer flex ">
                <div>
                    <img :src="toDataUrl(t.info.logo)" height="100" width="100" class="rounded-md" />
                </div>
                <div class="w-full pl-4">

                    <NuxtLink to="/team-info" @click="gotoInfo = true">
                        <Icon name="tabler:info-hexagon" size="2em" class="float-right text-white" />
                    </NuxtLink>
                    <Icon v-if="t.permissions.isAdmin" name="tabler:user-shield" size="2em"
                        class="float-right text-green-600" />
                    <Icon v-if="t.permissions.isMember" name="tabler:user-check" size="2em"
                        class="float-right text-green-600" />
                    <div class="text-2xl">
                        {{ t.info.name }}
                    </div>
                    <p class="whitespace-pre-wrap">
                        {{ t.info.about }}
                    </p>
                </div>
            </div>
        </NetworkDataContainer>

        <div class="w-full flex-grow" />
    </div>
</template>
