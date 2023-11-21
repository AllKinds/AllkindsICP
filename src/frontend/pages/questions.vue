<script lang="ts" setup>
definePageMeta({ title: "Project design" });

import { loadQuestions, createQuestion } from "~/helper/backend"

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

    await runNotify(createQuestion(q), "Question created successfully.").then(
        () => {
            question.value = "";
            loading.value = false;
            return loadQs();
        }
    );
}

if (inBrowser()) loadQs();
</script>


<template>
    <AllkindsTitle class="w-full">
        <div class="m-auto">Adam, 214 <Icon name="gg:shape-hexagon"></Icon>
        </div>

        <Icon name="prime:users" size="2em" />
    </AllkindsTitle>

    <NetworkDataContainer :networkdata="app.openQuestions" class="grow">
        <Question v-for="(q, i) in    app.openQuestions.data   " :question="q" :selected="i === 0" @answered="loadQs"
            @answering="app.removeQuestion(q as Question)">
            {{ i }}: {{ q.color }}
        </Question>
    </NetworkDataContainer>
</template>