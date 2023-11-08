
<script lang="ts" setup>
import { Question, answerQuestion } from '~/helper/backend';
import { Effect } from "effect"

const props = defineProps<{
    question: Question,
    selected?: boolean,
}>();

const q = props.question;
const selected = props.selected;
console.log("question is", q)

const answer = (q: number, a: boolean, boost: number) => {
    Effect.runPromise(answerQuestion(q, a, boost)).finally(() => { });
}

</script>

<template>
    <div class="w-full p-2">
        <div class="border border-gray-500 w-full p-2 rounded text-center collapse">
            <input type="radio" name="question-accordion" :checked="selected" />

            <span class="text-lg collapse-title">
                {{ q.question }}
            </span>

            <div class="collapse-content">
                <div class="badge badge-primary">
                    Boost
                </div>

                <div class="pt-2">
                    <Btn width="w-32" @click="answer(q.id, false, 0)">No</Btn>
                    <Btn width="w-0 " outline="outline-none">skip</Btn>
                    <Btn width="w-32">Yes</Btn>
                </div>
            </div>
        </div>
    </div>
</template>
