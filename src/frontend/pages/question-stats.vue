<script lang="ts" setup>

definePageMeta({
    title: "Allkinds",
    layout: 'default'
});

const app = useAppState();

if (inBrowser()) {
    app.getTeam();
    app.loadTeams(0);
    app.loadQuestionStats(0);
}

const deleteQuestion = (q: any) => { // TODO: replace type any with Question
    return app.deleteQuestion(q).then(
        () => app.loadQuestionStats(0)
    )
}

</script>

<template>
    <div class="w-full flex-grow">
        <AllkindsTitle logo="ph:x-circle" link-to="/team-info">
            <span />
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
                <Icon v-if="app.getTeam()?.permissions.isAdmin" name="tabler:user-shield" size="2em"
                    class="float-right text-green-600" />
                <Icon v-if="app.getTeam()?.permissions.isMember" name="tabler:user-check" size="2em"
                    class="float-right text-green-600" />
                <TextBlock>
                    <h2>About:</h2>
                    {{ app.getTeam()?.info.about }}
                </TextBlock>
            </div>

            <NetworkDataContainer :networkdata="app.getQuestionStats()" class="w-full text-left">
                <Question v-for="stats in app.getQuestionStats().data" :question="stats.question" :link="false"
                    :show-score="true">
                    <div class="w-full mt-4">
                        {{ stats.no }} no | {{ stats.yes }} yes
                        <Icon name="tabler:trash" class="float-right cursor-pointer"
                            @click="deleteQuestion(stats.question)" />
                    </div>
                </Question>
            </NetworkDataContainer>

        </NetworkDataContainer>
    </div>
</template>