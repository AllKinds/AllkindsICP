
<script lang="ts" setup>
import { Question, answerQuestion, skipQuestion } from '~/utils/backend';
import { notifyWithMsg } from '~/utils/errors';
import { Effect } from "effect"
const emit = defineEmits(["answered", "answering"]);

const props = defineProps<{
    question: Question,
    link?: boolean,
}>();

console.log("question is", props.question);

const q = props.question;

</script>

<template>
    <NuxtLink :to="'/answer-question/' + q.id" :class="getColor(q.color as ColorName).color"
        class="border p-4 w-full my-2 rounded-lg block text-2xl font-medium">
        <Icon v-if="props.link" name="material-symbols:arrow-forward-ios" class="float-right mt-1" />
        {{ q.question }}
    </NuxtLink>
</template>
