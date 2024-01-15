<script lang="ts" setup>

definePageMeta({
    title: "Allkinds",
    layout: 'default'
});

const app = useAppState();

if (inBrowser()) {
    app.getTeam();
    app.loadTeams(0);
    app.loadTeamStats(0);
}

const invite = (): string | undefined => {
    const team = app.getTeam();
    if (!team) return undefined;
    const code = app.getTeam()?.invite;
    if (!code?.length) return undefined;
    return document.location.origin + invitePath(app.getTeam()?.key || "", code[0]);
}
const copy = () => {
    const link = invite();
    if (link) {
        navigator.clipboard.writeText(link);
        addNotification('ok', "Invite link copied.")
    } else {
        addNotification('error', "Couldn't generate invite link.\nDo you have admin permissions?")
    }
}

const stats = () => {
    return app.getTeamStats().data
}

</script>

<template>
    <div class="w-full flex-grow">
        <AllkindsTitle logo="ph:x-circle" link-to="/select-team">
            <template #action>
                <NuxtLink to="/questions" slot="action">
                    <Icon name="mynaui:layers-three" size="2em" />
                </NuxtLink>
            </template>
        </AllkindsTitle>

        <NetworkDataContainer :networkdata="app.getTeams()" class="w-full text-lg">
            <div class="w-full text-center mb-8">
                <div class="inline-block">
                    <img :src="toDataUrl(app.getTeam()?.info.logo || [])" height="150" width="150" class="rounded-xl" />
                </div>
                <div class="text-2xl mt-4 w-full">
                    {{ app.getTeam()?.info.name }}
                </div>
                <div class="w-full">
                    Visibility: {{ app.getTeam()?.info.listed ? 'listed' : 'unlisted' }}
                </div>
                <NetworkDataContainer :networkdata="app.getTeamStats()" class="w-full text-left">
                    <b>{{ stats()?.users }}</b> users <br>
                    <b>{{ stats()?.questions }}</b> questions asked <br>
                    <b>{{ stats()?.answers }}</b> answers <br>
                    <b>{{ stats()?.users }}</b> connections created <br>
                </NetworkDataContainer>
                <Icon v-if="app.getTeam()?.permissions.isAdmin" name="tabler:user-shield" size="2em"
                    class="float-right text-green-600" />
                <Icon v-if="app.getTeam()?.permissions.isMember" name="tabler:user-check" size="2em"
                    class="float-right text-green-600" />
                <TextBlock>
                    <h2>About:</h2>
                    {{ app.getTeam()?.info.about }}
                </TextBlock>
            </div>

            <div class="text-center">
                <Btn class="w-80" @click="copy()" v-if="app.getTeam()?.permissions.isAdmin">Copy invite link</Btn>
                <Btn class="w-80" to="/questions">Ask and answer questions</Btn>
                <Btn class="w-80" to="/team-members" v-if="app.getTeam()?.permissions.isAdmin">Team members</Btn>
                <Btn class="w-80" to="/question-stats" v-if="app.getTeam()?.permissions.isAdmin">Manage questions</Btn>
                <Btn class="w-80">Watch demo</Btn>
            </div>

        </NetworkDataContainer>
    </div>
</template>