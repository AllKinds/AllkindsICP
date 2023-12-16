<script lang="ts" setup>
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
    console.log("answering question ", question, a, boost)
    app.removeQuestion(question)
    gotoNextQuestion = true;
    runNotify(answerQuestion(app.team, question.id.valueOf(), a, boost), "Answer saved").then(
        () => { app.loadQuestions() }
    ).catch(
        () => { app.loadQuestions() }
    );
}

// TODO: move to app
const skip = (question: Question) => {
    console.log('skipping', question)
    app.removeQuestion(question)
    gotoNextQuestion = true;
    runNotify(
        skipQuestion(app.team, question.id), "Question skipped"
    ).then(
        () => { app.loadQuestions() },
    ).catch(
        () => { app.loadQuestions() }
    );
}


let loaded = false;

function findQuestion(id: bigint, findOther = false) {
    const data = app.openQuestions.data;
    const data2 = app.answeredQuestions.data;
    let q = null;
    if (!data) {
        if (!loaded) {
            loaded = true;
            app.loadQuestions();
        }
    } else if (data.length === 0) {
        navigateTo("/questions");
    } else if (gotoNextQuestion) {
        navigateTo("/answer-question/" + data[0].id);
    } else {
        q = data.find((x) => x.id === id);
        if (!q && data2) {
            q = data2.find((x) => x.id === id);
        }
        if (!q) {
            // goto next question
            navigateTo("/answer-question/" + data[0].id);
        }
    }

    return q;
}

let q = () => findQuestion(BigInt(route.params.id as string)) || {} as Question;

if (inBrowser()) {
    app.loadUser();
}

const twColor = () => getColor(q().color as ColorName).color;

</script>

<template>
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

        <div class="w-full mt-3 flex flex-row place-content-evenly">
            <NuxtLink class="p-7 link" :class="{ 'text-gray-500 pointer-events-none': weight <= 1 }"
                @click="weight = Math.max(1, weight - 1)">
                <Icon name="ph:minus-circle" size="2em" />
            </NuxtLink>
            <div class="text-center relative">
                <Icon name="gg:shape-hexagon" size="5em" />
                <div class="absolute top-7 w-full text-center">+{{ weight }}</div>

                <div class="w-full text-center mb-3">Importance</div>
            </div>
            <NuxtLink class="p-7 link" :class="{ 'text-gray-500 pointer-events-none': weight >= 5 }"
                @click="weight = Math.min(5, weight + 1)">
                <Icon name="ph:plus-circle" size="2em" />
            </NuxtLink>
        </div>

        <div class="flex flex-row place-content-evenly">
            <Btn width="w-32" @click="answer(q(), false, weight)">No</Btn>
            <Btn width="w-32" @click="answer(q(), true, weight)">Yes</Btn>
        </div>
        <div class="flex flex-row place-content-evenly">
            <NuxtLink width="w-72 link" @click="skip(q())">Skip</NuxtLink>
        </div>
    </div>
    <div class="grow w-full rounded-b-xl" :class="twColor()" />
</template>
