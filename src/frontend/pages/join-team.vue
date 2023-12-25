<script lang="ts" setup>

definePageMeta({ title: "Welcome" });
const app = useAppState();
const invite = useState("invite-code", () => "");

if (inBrowser()) {
    app.loadTeams(0)
}

const getTeam = () => app.getTeam();

const join = () => {
    app.joinTeam(invite.value).then(() => { navigateTo("/questions") });
}

</script>

<template>
    <AllkindsTitle link-to="/welcome">Allkinds.teams</AllkindsTitle>
    <TextBlock>
        <h1>Join a team</h1>
    </TextBlock>

    <NetworkDataContainer :networkdata="app.getTeams()" class="w-full flex-grow flex flex-col">

        <img :src="toDataUrl(app.getTeam()?.info.logo || [])" height="150" width="150" class="m-auto rounded-2xl" />

        <div class="w-full text-center mt-4 mb-8 text-lg">
            Enter invite code for <span class="font-bold">{{ getTeam()?.info.name }} ({{ app.team }})</span>
        </div>

        <div class="p-4 rounded-lg my-2 w-full">
            <p>
                {{ getTeam()?.info.about }}
            </p>
        </div>

        <div class="w-2 flex-grow"></div>

        <div class="text-center w-full mt-4">
            <TextInput v-model.trim="invite" placeholder="invite-code" class="text-center" />

        </div>
        <div class="w-2 flex-grow"></div>

        <div class="text-center w-full mt-4">
            <Btn @click="join()">Join the team</Btn> <!-- TODO: loading indicator -->
        </div>
        <div class="w-2 flex-grow"></div>
    </NetworkDataContainer>
</template>
