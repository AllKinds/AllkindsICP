<script type="ts" setup>
import { Effect } from "effect";
import { loadQuestions } from "~/utils/backend"
import { getColor } from "~/utils/color";

const route = useRoute();
const question = useState('new-question', () => "")
const app = useAppState();
const loading = useState("loading", () => false);
const color = useState('color', () => "green")
const weight = useState('weight', () => 1)
weight.value = 1;

const answer = (question, a, boost) => {
    console.log("answering question ", question, a, boost)
    app.removeQuestion(question)
    navigateTo("/questions") // TODO: goto next question
    runNotify(answerQuestion(question.id.valueOf(), a, boost), "Answer saved").then(
        () => { loadQs() }
    );
}

const skip = (question) => {
    console.log('skipping', question)
    app.removeQuestion(question)
    navigateTo("/questions") // TODO: goto next question
    runNotify()
    Effect.runPromise(
        skipQuestion(question.id.valueOf()).pipe(notifyWithMsg("Question skipped"))
    ).then(
        () => { loadQs() }
    );
}

async function loadQs() {
    console.log("loading questions")
    runStoreNotify(loadQuestions(), app.setOpenQuestions)
}

let loaded = false;

function findQuestion(id) {
    const data = app.openQuestions.data;
    let q = null;
    if (!data) {
        if (!loaded) {
            loaded = true;
            loadQs()
                .catch(() => navigateTo("/questions"));
        }
    } else if (data.length === 0) {
        navigateTo("/questions");
    } else {
        q = data.find((x) => x.id == id);
        if (!q) {
            navigateTo("/answer-question/" + data[0].id);
        }
    }

    return q;
}

let q = () => findQuestion(route.params.id) || {};

runStoreNotify(loadUser(), app.setUser);

const twColor = () => getColor(q().color).color;

</script>

<template>
    <AllkindsTitle class="w-full" logo="ph:x-circle" linkTo="/questions">
        <div class="m-auto">{{ app.user.data?.username || '-' }}, 214 <Icon name="gg:shape-hexagon"></Icon>
        </div>

        <Icon name="prime:users" size="2em" />
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
