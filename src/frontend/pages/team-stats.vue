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
    app.loadQuestionStats(0);
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
        <AllkindsTitle link-to="/select-team">
            <span />
            <template #action>
                <IconLink to="/questions" />
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
                    <b>{{ stats()?.connections }}</b> connections created <br>
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
        </NetworkDataContainer>

        <NetworkDataContainer :networkdata="app.getQuestionStats()" class="w-full text-left">
            <Question v-for="stats in app.getQuestionStats().data" :question="stats.question" :link="false">
                <div class="w-full mt-4">
                    {{ stats.no }} no | {{ stats.yes }} yes
                </div>
            </Question>
        </NetworkDataContainer>

    </div>
</template>
