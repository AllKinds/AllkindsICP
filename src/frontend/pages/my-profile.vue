<script lang="ts" setup>
definePageMeta({ title: "My profile" });

const app = useAppState();

if (inBrowser()) {
    app.loadUser();
    app.loadAnsweredQuestions();
    app.loadOwnQuestions();
}
</script>


<template>
    <AllkindsTitle logo="ph:x-circle" logoSize="2em" linkTo="/questions">
        <NuxtLink to="/my-profile" class="m-auto">
        </NuxtLink>

        <NuxtLink to="/settings">
            <Icon name="ph:gear" size="2em" />
        </NuxtLink>
    </AllkindsTitle>

    <div class="w-full">
        <div class="text-3xl font-bold">
            {{ app.getUser().username }}, {{ app.getUser().points }}
            <Icon name="gg:shape-hexagon" class="mb-2" />
        </div>
        <div>
            <span class="font-bold">{{ /* app.getUser().stats.asked */ 8 }}</span>
            questions asked
        </div>
        <div>
            <span class="font-bold">{{ /* app.getUser().stats.answered */ 77 }}</span>
            questions answered
        </div>
        <div>
            <span class="font-bold">{{ /* app.getUser().stats.boosts */ 6 }}</span>
            people boosted your question
        </div>
    </div>

    <div class="w-full text-xl font-bold mt-4">Your questions</div>
    <NetworkDataContainer :networkdata="app.getOwnQuestions()" class="grow mt-4 w-full">
        <NuxtLink v-for="(q, i) in app.getOwnQuestions().data" :question="q" :selected="i === 0"
            :to="'/answer-question/' + q.id" :class="getColor(q.color as ColorName).color"
            class="border p-4 w-full my-2 rounded-lg block text-2xl font-medium">
            <Icon name="material-symbols:arrow-forward-ios" class="float-right mt-1" />
            {{ q.question }}
        </NuxtLink>
        <div v-if="app.getOwnQuestions().data?.length === 0" class="w-full">
            You have not asked a question yet.
            <div class="w-full text-center my-10">
                <Btn to="/ask-question" class="w-64">Ask a question</Btn>
            </div>
        </div>
    </NetworkDataContainer>

    <div class="w-full text-xl font-bold mt-4">Answered questions</div>
    <NetworkDataContainer :networkdata="app.getAnsweredQuestions()" class="grow mt-4 w-full">
        <NuxtLink v-for="([q, a], i) in app.getAnsweredQuestions().data" :question="q" :selected="i === 0"
            :to="'/answer-question/' + q.id" :class="getColor(q.color as ColorName).color"
            class="border p-4 w-full my-2 rounded-lg block text-2xl font-medium">
            <Icon name="material-symbols:arrow-forward-ios" class="float-right mt-1" />
            {{ q.question }}
        </NuxtLink>
        <div v-if="app.getAnsweredQuestions().data?.length === 0" class="w-full">
            You have no answers yet.
            <div class="w-full text-center my-10">
                <Btn to="/questions" class="w-64">Answer questions</Btn>
            </div>
        </div>
    </NetworkDataContainer>
</template>