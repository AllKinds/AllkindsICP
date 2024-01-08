<script lang="ts" setup>
import { withDefault, UserPermissions } from '../utils/backend';

definePageMeta({
    title: "Allkinds",
    layout: 'default'
});

const app = useAppState();

const user = () => {
    const dummy = { user: { stats: {} }, permissions: {} } as UserPermissions;
    return withDefault(app.getUser(), dummy).user;
};

if (inBrowser()) {
    app.getTeam();
    app.loadUser(0);
    app.loadAnsweredQuestions();
    app.loadOwnQuestions();
}
</script>


<template>
    <div class="w-full flex-grow">
        <AllkindsTitle logo="ph:x-circle" logoSize="2em" linkTo="/questions">

            <template #action>
                <NuxtLink to="/settings">
                    <Icon name="ph:gear" size="2em" />
                </NuxtLink>
            </template>
        </AllkindsTitle>

        <div class="w-full">
            <div class="text-3xl font-bold">
                {{ user().displayName }}, {{ user().stats.points }}
                <Icon name="gg:shape-hexagon" class="mb-2" />
            </div>
            <div>
                <span class="font-bold">{{ user().stats.asked }}</span>
                questions asked
            </div>
            <div>
                <span class="font-bold">{{ user().stats.answered }}</span>
                questions answered
            </div>
            <div>
                <span class="font-bold">{{ user().stats.boosts }}</span>
                people boosted your question
            </div>
        </div>

        <div class="w-full text-xl font-bold mt-4">Your questions</div>
        <NetworkDataContainer :networkdata="app.getOwnQuestions()" class="grow mt-4 w-full">
            <Question v-for="(q, i) in app.getOwnQuestions().data" :question="q" :showScore="true" :link="true" />
            <div v-if="app.getOwnQuestions().data?.length === 0" class="w-full">
                You have not asked a question yet.
                <div class="w-full text-center my-10">
                    <Btn to="/ask-question" class="w-64">Ask a question</Btn>
                </div>
            </div>
        </NetworkDataContainer>

        <div class="w-full text-xl font-bold mt-4">Answered questions</div>
        <NetworkDataContainer :networkdata="app.getAnsweredQuestions()" class="grow mt-4 w-full">
            <Question v-for="([q, a], i) in app.getAnsweredQuestions().data" :question="q" :link="true" />

            <div v-if="app.getAnsweredQuestions().data?.length === 0" class="w-full">
                You have no answers yet.
                <div class="w-full text-center my-10">
                    <Btn to="/questions" class="w-64">Answer questions</Btn>
                </div>
            </div>
        </NetworkDataContainer>
    </div>
</template>