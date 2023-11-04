<script type="ts" setup>
import { Effect } from "effect";
import { loadQuestions } from "../helper/backend"

function resize(el) {
    const t = el.target;
    t.style.height = "auto";
    const border = t.style.borderTopWidth * 2;
    const height = el.target.scrollHeight;
    const total = border + height + 2;
    el.target.style.setProperty('height', (total) + 'px');
}
const question = useState('new-question', () => "")
const app = useAppState();

function loadQs() {
    console.log("loading questions")
    Effect.runPromise(
        Effect.match(loadQuestions(), {
            onSuccess: (qs) => {
                addNotification(app.value, "ok", "Questions loaded"); app.value.openQuestions = qs
            },
            onFailure: (e) => { addNotification(app.value, "error", "err: " + e.err) },
        })
    );
}

function create() {
    const q = question.value;
    Effect.runPromise(createQuestion(q)).then(
        () => { addNotification(app.value, "ok", "Question created successfully.") },
        (e) => { addNotification(app.value, "error", "err" + e) },
    );
}

</script>

<template>
    <div class="p-5 w-full max-w-xl">
        <TextArea style="min-height: 1em !important" @on:keyup.enter="create" v-model="question"
            placeholder="Ask a Yes/No question…"></TextArea>
    </div>

    <div v-for="n in app.notifications">
        <div class="alert" :class="{ 'alert-error': n.level === 'error', 'alert-success': n.level === 'ok' }">
            {{ n.msg }}
        </div>
    </div>

    <div class="border w-full">
        <div v-for="i in app.openQuestions" class="w-full">i.question</div>
        <div v-if="app.openQuestions?.length === 0">No unanswered questions available</div>
        <div v-if="app.openQuestions === undefined">Loading questions...</div>
        <Btn @click="loadQs">Reload questions</Btn>
    </div>
</template>
