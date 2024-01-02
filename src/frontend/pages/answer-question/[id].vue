<script lang="ts" setup>

definePageMeta({
    title: "Contacts",
    layout: 'default'
});

import { ColorName, getColor } from "../../utils/color";
import { Question } from "../../utils/backend";

const route = useRoute();
const question = useState('new-question', () => "")
const app = useAppState();
const loading = useState("loading", () => false);
const color = useState('color', () => "green")
const weight = useState('weight', () => 1)
weight.value = 1;
let gotoNextQuestion = false;

// TODO: move to app
const answer = (question: Question, a: boolean, boost: number) => {
    // TODO: show background task pending indicator
    console.log("answering question ", question, a, boost)
    app.removeOpenQuestion(question)
    gotoNextQuestion = true;
    runNotify(answerQuestion(app.team, question.id.valueOf(), a, boost), "1 Answer saved").then(
        () => { app.loadOpenQuestions() }
    ).catch(
        () => { app.loadOpenQuestions() }
    );
}

// TODO: move to app
const skip = (question: Question) => {
    // TODO: show background task pending indicator
    console.log('skipping', question)
    app.removeOpenQuestion(question)
    gotoNextQuestion = true;
    runNotify(
        skipQuestion(app.team, question.id), "Question skipped"
    ).then(
        () => { app.loadOpenQuestions() },
    ).catch(
        () => { app.loadOpenQuestions() }
    );
}


let loaded = false;

function findQuestion(id: bigint, findOther = false) {
    const data = app.openQuestions.data;
    const data2 = app.getAnsweredQuestions().data;
    let q = null;
    if (!data) {
        if (!loaded) {
            loaded = true;
            app.loadOpenQuestions();
        }
    } else if (data.length === 0 && gotoNextQuestion) {
        navigateTo("/questions");
    } else if (gotoNextQuestion) {
        navigateTo("/answer-question/" + data[0].id);
    } else {
        q = data.find((x) => x.id === id);
        if (!q && data2) {
            q = data2.find((x) => x[0].id === id)?.[0];
        }
        if (!q) {
            // goto next question
            if (data.length === 0) navigateTo("/questions");
            else navigateTo("/answer-question/" + data[0].id);
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

</script>

<template>
    <div class="w-full flex-grow flex flex-col">
        <AllkindsTitle class="w-full" logo="ph:x-circle" linkTo="/questions">
            <NuxtLink to="/my-profile" class="m-auto">
                {{ app.getUser().displayName }}, {{ app.getUser().stats.points }}
                <Icon name="gg:shape-hexagon" class="mb-2" />
            </NuxtLink>

            <NuxtLink to="/contacts">
                <Icon name="prime:users" size="2em" />
            </NuxtLink>
        </AllkindsTitle>

        <div class="grow w-full rounded-t-xl" :class="twColor()" />

        <div class="p-5 w-full max-w-xl" :class="twColor()">
            <div v-if="loading" class="text-center w-full">
                <Icon name="line-md:loading-alt-loop" size="5em" class="absolute mt-8" />
            </div>
            <span class="text-2xl">
                {{ q().question }}
            </span>
        </div>

        <div class="grow w-full" :class="twColor()" />
        <div class="grow w-full" :class="twColor()" />

        <div class="w-full" :class="twColor()">

            <Importance v-model="weight" />

            <div class="flex flex-row place-content-evenly mt-4">
                <Btn width="w-32" @click="answer(q(), false, weight)">No</Btn>
                <Btn width="w-32" @click="answer(q(), true, weight)">Yes</Btn>
            </div>
            <div class="flex flex-row place-content-evenly">
                <NuxtLink class="link" @click="skip(q())">Skip</NuxtLink>
            </div>
        </div>
        <div class="grow w-full rounded-b-xl" :class="twColor()" />
    </div>
</template>
