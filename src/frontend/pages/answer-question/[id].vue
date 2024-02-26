<script lang="ts" setup>

definePageMeta({
    title: "Contacts",
    layout: 'default'
});

import { type ColorName, getColor } from "../../utils/color";
import { type Question } from "../../utils/backend";

const route = useRoute();
const app = useAppState();
const loading = useState("loading", () => false);
const weight = useState('weight', () => 1)
weight.value = 1;
let gotoNextQuestion = false;
let disappearing: Question | null = null;

// TODO: move to app
const answer = (question: Question, a: boolean, boost: number) => {
    if (isLoading()) return;
    // TODO: show background task pending indicator
    console.log("answering question ", question, a, boost)
    disappearing = question;
    app.removeOpenQuestion(question);
    loading.value = true;
    setTimeout(() => {
        disappearing = null
        loading.value = false;
    }, 600); // fake delay
    gotoNextQuestion = true;
    runNotify(answerQuestion(app.team, question.id.valueOf(), a, boost)).then(
        () => {
            if ((app.openQuestions.data?.length || 0) > 2) { app.loadOpenQuestions() }
            else { app.loadOpenQuestions(0) }
        }
    ).catch(
        () => { app.loadOpenQuestions(0) }
    );
}

// TODO: move to app
const skip = (question: Question) => {
    if (isLoading()) return;
    // TODO: show background task pending indicator
    console.log('skipping', question)
    app.removeOpenQuestion(question)
    disappearing = question;
    gotoNextQuestion = true;
    loading.value = true;
    setTimeout(() => {
        disappearing = null
        loading.value = false;
    }, 600); // fake delay
    runNotify(
        skipQuestion(app.team, question.id), "Question skipped"
    ).then(
        () => {
            if ((app.openQuestions.data?.length || 0) > 2) { app.loadOpenQuestions() }
            else { app.loadOpenQuestions(0) }
        },
    ).catch(
        () => { app.loadOpenQuestions(0) }
    );
}


let loaded = false;
let navigatedAway = false;

function findQuestion(id: bigint, findOther = false): Question | null {
    if (disappearing) return disappearing;

    let data = app.openQuestions.data;
    const data2 = app.getAnsweredQuestions().data;
    let q: Question | null = null;
    if (!data) {
        if (!loaded) {
            loaded = true;
            app.loadOpenQuestions();
        }
    } else if (data.length === 0 && gotoNextQuestion) {
        if (!navigatedAway) navTo("/questions");
        navigatedAway = true;
    } else if (gotoNextQuestion) {
        const nextId = data[0].id;
        gotoNextQuestion = false;
        if (!navigatedAway) navTo("/answer-question/" + nextId)
        navigatedAway = true;
    } else {
        q = data.find((x) => x.id === id) ?? null;
        if (!q && data2) {
            q = data2.find((x) => x[0].id === id)?.[0] ?? null;
        }
        if (!q) {
            // goto next question
            if (data.length === 0) navTo("/questions");
            else {
                if (!navigatedAway) navTo("/answer-question/" + data[0].id);
                navigatedAway = true;
            }
        }
    }

    return q;
}

let q = () => findQuestion(BigInt(route.params.id as string)) || {} as Question;

if (inBrowser()) {
    app.getTeam();
    app.loadUser();
}

const twColor = () => getColor(q().color as ColorName).color;
const user = () => app.getUser().data?.user;
const isLoading = () => loading.value || gotoNextQuestion;

</script>

<template>
    <div class="w-full flex-grow flex flex-col">
        <AllkindsTitle class="w-full" logo="x" linkTo="/questions">
            <NuxtLink to="/my-profile" class="m-auto">
                {{ user()?.displayName }}, {{ user()?.stats.points }}
                <Icon name="gg:shape-hexagon" class="mb-2" />
            </NuxtLink>

            <template #action>
                <IconLink to="/discover" />
            </template>
        </AllkindsTitle>

        <div class="grow w-full rounded-t-xl" :class="twColor()" />

        <div class="p-5 w-full max-w-xl" :class="twColor()">
            <div v-if="isLoading()" class="text-center w-full">
                <Icon name="line-md:loading-alt-loop" size="5em" class="absolute mt-8" />
            </div>
            <div class="text-4xl text-center">
                {{ q().question }}
            </div>
        </div>

        <div class="grow w-full" :class="twColor()" />
        <div class="grow w-full" :class="twColor()" />

        <div class="w-full" :class="twColor()">

            <Importance v-model="weight" />

            <div class="flex flex-row place-content-evenly mt-4 items-baseline">
                <Btn width="w-32" @click="answer(q(), false, weight)">No</Btn>
                <NuxtLink class="link" @click="skip(q())">Skip</NuxtLink>
                <Btn width="w-32" @click="answer(q(), true, weight)">Yes</Btn>
            </div>
        </div>
        <div class="grow w-full rounded-b-xl" :class="twColor()" />
    </div>
</template>
