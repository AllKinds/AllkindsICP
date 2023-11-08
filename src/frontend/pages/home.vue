<script type="ts" setup>
import { Effect } from "effect";
import { loadQuestions, createQuestion } from "~/helper/backend"
import { orNotify } from "~/helper/errors";

const question = useState('new-question', () => "")
const app = useAppState();
const loading = useState("loading", () => false);

function loadQs() {
    app.value.openQuestions = undefined;
    console.log("loading questions")
    Effect.runPromise(
        orNotify(loadQuestions())
    ).then((qs) => app.value.openQuestions = qs);
}

function create() {
    loading.value = true;
    const q = question.value;
    Effect.runPromise(orNotify(createQuestion(q))).then(() => {
        addNotification("ok", "Question created successfully.")
        question.value = "";
        loadQs();
    }).finally(() => loading.value = false);
}

loadQs();

</script>

<template>
    <div class="p-5 w-full max-w-xl">
        <TextArea style="min-height: 1em !important" @on:keyup.enter="create" v-model="question"
            placeholder="Ask a Yes/No question…"></TextArea>
        <Btn v-if="question.length > 0" @click="create" :class="{ 'btn-disabled': question.length <= 10 }">Create</Btn>
    </div>


    <div v-for=" n  in  app.notifications ">
        <div class="alert" :class="{ 'alert-error': n.level === 'error', 'alert-success': n.level === 'ok' }">
            {{ n.msg }}
        </div>
    </div>

    <div class="w-full">
        <Question v-for="(q, i) in app.openQuestions" :question="q" :selected="i === 0">
        </Question>
        <div v-if="app.openQuestions?.length === 0">No unanswered questions available</div>
        <div v-if="app.openQuestions === undefined">Loading questions...</div>
        <Btn class="btn-secondary" @click="loadQs">Reload questions</Btn>
    </div>
</template>
