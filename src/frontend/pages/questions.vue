<script lang="ts" setup>
definePageMeta({ title: "Project design" });

import { loadQuestions, createQuestion } from "~/utils/backend"
import { getColor } from "~/utils/color"

const question = useState('new-question', () => "")
const app = useAppState();
const loading = useState("loading", () => false);

async function loadQs() {
    console.log("loading questions")
    runStoreNotify(loadQuestions(), app.setOpenQuestions)
}

async function create() {
    loading.value = true;
    const q = question.value;

    await runNotify(createQuestion(q, "black"), "Question created successfully.").then(
        () => {
            question.value = "";
            loading.value = false;
            return loadQs();
        }
    );
}

if (inBrowser()) {
    loadQs();
} else {
    //app.openQuestions.status = "init";
}
</script>


<template>
    <AllkindsTitle>
        <div class="m-auto">Adam, 214 <Icon name="gg:shape-hexagon"></Icon>
        </div>

        <Icon name="prime:users" size="2em" />
    </AllkindsTitle>

    <NuxtLink to="/ask-question" class="w-full rounded bg-slate-100 text-gray-500 text-xl p-5 cursor-text">
        Ask your yes/no question
    </NuxtLink>

    <NetworkDataContainer :networkdata="app.openQuestions" class="grow mt-4 w-full">
        <NuxtLink v-for="(q, i) in app.openQuestions.data" :question="q" :selected="i === 0"
            :to="'/answer-question/' + q.id" :class="getColor(q.color as ColorName).color"
            class="border p-4 w-full my-2 rounded-lg block text-2xl font-medium">
            <Icon name="material-symbols:arrow-forward-ios" class="float-right mt-1" />
            {{ q.question }}
        </NuxtLink>
    </NetworkDataContainer>
</template>