<script type="ts" setup>
import { Effect } from "effect";
import { loadQuestions, createQuestion } from "~/helper/backend"
import { notifyWithMsg } from "~/helper/errors";

const question = useState('new-question', () => "")
const app = useAppState();
const loading = useState("loading", () => false);

async function loadQs() {
    console.log("loading questions")
    await Effect.runPromise(
        storeToData(loadQuestions().pipe(notifyWithMsg()), app.setOpenQuestions));
}

function create() {
    loading.value = true;
    const q = question.value;
    Effect.runPromise(
        createQuestion(q).pipe(notifyWithMsg("Question created successfully."))).then(
            () => {
                question.value = "";
                loadQs();
            }
        )
}

loadQs();

async function test() {
    const delay = ms => new Promise(res => setTimeout(res, ms));
    app.setOpenQuestions({ status: "requested" })
    await delay(2000)
    app.setOpenQuestions({ status: "ok", data: [] })
    await delay(2000)
    app.setOpenQuestions({ status: "error" })
}

</script>

<template>
    <Btn @click="console.log(app); test()">asdf</Btn>
    <div class="p-5 w-full max-w-xl">
        <TextArea style="min-height: 1em !important" @ctrl-enter="create" v-model="question"
            placeholder="Ask a Yes/No question…"></TextArea>
        <Btn v-if="question.length > 0" @click="create" :class="{ 'btn-disabled': question.length <= 10 }">Create</Btn>
        <Btn v-if="question.length > 0" @click="question = ''">cancel</Btn>
    </div>

    {{ app.openQuestions.status }}

    <div class="w-full">
        <Question v-for="(q, i) in app.openQuestions.data" :question="q" :selected="i === 0" @answered="loadQs">
            {{ i }}: {{ q }}
        </Question>
        <div v-if="app.openQuestions.data?.length === 0">No unanswered questions available</div>
        <div v-if="app.openQuestions.status === 'requested'">Loading questions...</div>
        <Btn class="btn-secondary" @click="loadQs">Reload questions</Btn>
    </div>
</template>
