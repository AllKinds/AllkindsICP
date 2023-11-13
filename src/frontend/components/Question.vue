
<script lang="ts" setup>
import { Question, answerQuestion, skipQuestion } from '~/helper/backend';
import { notifyWithMsg } from '~/helper/errors';
import { Effect } from "effect"
const emit = defineEmits(["answered"]);

const props = defineProps<{
    question: Question,
    selected?: boolean,
}>();

console.log("question is", props.question);

const q = props.question;
const selected = props.selected;

const answer = (q: BigInt, a: boolean, boost: number) => {
    console.log("answering question ", q, a, boost)
    Effect.runPromise(
        answerQuestion(q.valueOf(), a, boost).pipe(notifyWithMsg("Answer saved"))
    ).then(
        () => { emit('answered', a); }
    );
}

const skip = (q: BigInt) => {
    Effect.runPromise(
        skipQuestion(q.valueOf()).pipe(notifyWithMsg("Question skipped"))
    ).then(
        () => { emit('answered', props.question); }
    );
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
                    Boost {{ q.id }}
                </div>

                <div class="pt-2">
                    <Btn width="w-32" @click="answer(q.id, false, 0)">No</Btn>
                    <Lnk width="w-0 " @click="skip(q.id)">skip</Lnk>
                    <Btn width="w-32" @click="answer(q.id, false, 0)">Yes</Btn>
                </div>
            </div>
        </div>
    </div>
</template>
