<script type="ts" setup>
import { Effect } from "effect";
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

loadQs();

</script>

<template>
    <div class="p-5 w-full max-w-xl">
        <div v-if="loading" class="text-center w-full">
            <Icon name="line-md:loading-alt-loop" size="5em" class="absolute mt-8" />
        </div>
        <TextArea style="min-height: 1em !important" @ctrl-enter="create" v-model="question"
            placeholder="Ask a Yes/No question…" :class="{ 'input-disabled': loading }"></TextArea>
        <Btn v-if="question.length > 0" @click="create" :class="{ 'btn-disabled': (question.length <= 10 || loading) }">
            Create</Btn>
        <Btn v-if="question.length > 0" @click="question = ''" :class="{ 'btn-disabled': (loading) }">cancel</Btn>
    </div>

    {{ app.openQuestions.status }}

    <div class="w-full">
        <NetworkDataContainer :networkdata="app.openQuestions">
            <Question v-for="(q, i) in app.openQuestions.data" :question="q" :selected="i === 0" @answered="loadQs"
                @answering="app.removeQuestion(q)">
                {{ i }}: {{ q.color }}
            </Question>
        </NetworkDataContainer>
        <div v-if="app.openQuestions.data?.length === 0">No unanswered questions available</div>
        <div v-if="app.openQuestions.status === 'requested'">Loading questions...</div>
        <Btn class="btn-secondary" @click="loadQs">Reload questions</Btn>
    </div>
</template>
