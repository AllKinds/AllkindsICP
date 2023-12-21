<script lang="ts" setup>
import { TeamUserInfo } from '~/utils/backend';


definePageMeta({ title: "Welcome" });
const app = useAppState();
const invite = useState("invite-code", () => "");

if (inBrowser()) {
    const ref = document.location.hash
    try {
        const team = ref.split(":")[0].replace(/[^a-z]/g, "");
        const code = ref.split(":")[1];
        if (team.length < 2) throw "";
        invite.value = code;
        app.loadTeams(0, team); // TODO: auto select team if it exists
    } catch {
        app.loadTeams(0)
    }

}

const setTeam = (t: TeamUserInfo) => {
    app.setTeam(t.key);
    if (t.permissions.isMember) {
        navigateTo("/questions")
    } else {
        navigateTo("/join-team")
    }
}

</script>

<template>
    <AllkindsTitle>Welcome</AllkindsTitle>
    <TextBlock align="text-center">
        <h1>Welcome to Allkinds.teams</h1>
    </TextBlock>

    <NetworkDataContainer :networkdata="app.getTeams()" class="w-full text-lg">
        <div class="w-full text-center mb-8">
            Available teams: {{ app.getTeams().data?.length }}
        </div>

        <div v-for="t in app.getTeams().data" @click="setTeam(t)"
            class="border border-white p-4 rounded-lg my-2 w-full cursor-pointer">
            <Icon name="material-symbols:arrow-forward-ios" class="float-right mt-1" />

            <Icon v-if="t.permissions.isAdmin" name="tabler:user-shield" size="2em" class="float-right text-green-600" />
            <Icon v-if="t.permissions.isMember" name="tabler:user-check" size="2em" class="float-right text-green-600" />
            <div class="text-2xl">
                {{ t.info.name }}
            </div>
            <p>
                {{ t.info.about }}
            </p>

        </div>
    </NetworkDataContainer>
</template>
