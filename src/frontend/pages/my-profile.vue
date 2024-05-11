<script lang="ts" setup>
import { copyPersonalInvite } from '~/composables/appState';
import { withDefault, type Question, type UserPermissions } from '../utils/backend';

definePageMeta({
    title: "Allkinds",
    footerMenu: true,
});

const app = useAppState();

const loading = ref<Question|null>(null);

const user = () => {
    const dummy = { user: { stats: {} }, permissions: {} } as UserPermissions;
    return withDefault(app.getUser(), dummy).user;
};


const deleteQuestion = (q: any) => { // TODO: replace type any with Question
    if (confirm("Hide this question?\n\nUsers who already answered the question will still see it.")){
        loading.value = q;
        return app.deleteQuestion(q, true).then(
            () => app.loadOwnQuestions(0),
            console.error,
        ).finally(
            () => { loading.value = null }
        );
    }
}

const recoverQuestion = (q: any) => { // TODO: replace type any with Question
    if (confirm("Recover this question?")){
        loading.value = q;
        return app.deleteQuestion(q, false).then(
            () => app.loadOwnQuestions(0),
            console.error,
        ).finally(
            () => { loading.value = null }
        );
    }
}


if (inBrowser()) {
    app.getTeam();
    app.loadTeams();
    app.loadUser(0);
    app.loadAnsweredQuestions();
    app.loadOwnQuestions();
}

</script>

<template>
    <div class="w-full flex-grow">
        <AllkindsTitle>
            <span />
            <template #action>
                <IconLink to="/settings" />
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

        <div class="w-full mt-4">
            <div class="text-xl font-bold">
                Invite others to join the tribe
            </div>
            People invited via this link will be asked your questions first.
            <div class="w-full text-center">
                <Btn class="w-72" @click="copyPersonalInvite()">Copy personal invite link</Btn>
            </div>
        </div>

        <div class="w-full text-xl font-bold mt-4">Your questions</div>
        <NetworkDataContainer :networkdata="app.getOwnQuestions()" class="grow mt-4 w-full">
            <Question v-for="(q, _i) in app.getOwnQuestions().data" :question="q" :showScore="true" :link="true"
                :deleteable="true" @delete="deleteQuestion" @recover="recoverQuestion" :loading="q.id === loading?.id">
            </Question>
            <div v-if="app.getOwnQuestions().data?.length === 0" class="w-full">
                You have not asked a question yet.
                <div class="w-full text-center my-10">
                    <Btn to="/ask-question" class="w-64">Ask a question</Btn>
                </div>
            </div>
        </NetworkDataContainer>

        <div class="w-full text-xl font-bold mt-4">Answered questions</div>
        <NetworkDataContainer :networkdata="app.getAnsweredQuestions()" class="grow mt-4 w-full">
            <Question v-for="([q, _a], _i) in app.getAnsweredQuestions().data" :question="q" :link="true" />

            <div v-if="app.getAnsweredQuestions().data?.length === 0" class="w-full">
                You have no answers yet.
                <div class="w-full text-center my-10">
                    <Btn to="/questions" class="w-64">Answer questions</Btn>
                </div>
            </div>
        </NetworkDataContainer>
    </div>
</template>
