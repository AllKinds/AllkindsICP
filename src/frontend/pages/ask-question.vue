<script type="ts" setup>
import { Effect } from "effect";
import { loadQuestions, createQuestion } from "~/utils/backend"
import { colors } from "~/utils/color";

const question = useState('new-question', () => "")
const app = useAppState();
const loading = useState("loading", () => false);
const color = useState('color', () => "green")
const weight = useState('weight', () => 1)

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

</script>

<template>
    <AllkindsTitle class="w-full" logo="ph:x-circle">
        <div class="m-auto">Adam, 214 <Icon name="gg:shape-hexagon"></Icon>
        </div>

        <Icon name="prime:users" size="2em" />
    </AllkindsTitle>

    <div class="grow w-full rounded-t-xl" :class="colors[color].color" />

    <div class="p-5 w-full max-w-xl" :class="colors[color].color">
        <div v-if="loading" class="text-center w-full">
            <Icon name="line-md:loading-alt-loop" size="5em" class="absolute mt-8" />
        </div>
        <TextArea style="min-height: 1em !important" @ctrl-enter="create" v-model="question"
            placeholder="Ask a Yes/No question…" :class="{ 'input-disabled': loading }"></TextArea>
        <Btn v-if="question.length > 0" @click="create" :class="{ 'btn-disabled': (question.length <= 10 || loading) }">
            Create</Btn>
        <Btn v-if="question.length > 0" @click="question = ''" :class="{ 'btn-disabled': (loading) }">cancel</Btn>
    </div>

    <div class="grow w-full" :class="colors[color].color" />
    <div class="grow w-full" :class="colors[color].color" />

    <div class="w-full" :class="colors[color].color">
        <ColorPicker v-model="color" />

        <div class="w-full mt-3 flex flex-row place-content-evenly">
            <NuxtLink class="p-7 link" :class="{ 'text-gray-500': weight <= 1 }" @click="weight = Math.max(1, weight - 1)">
                <Icon name="ph:minus-circle" size="2em" />
            </NuxtLink>
            <div class="text-center relative">
                <Icon name="gg:shape-hexagon" size="5em" />
                <div class="absolute top-7 w-full text-center">+{{ weight }}</div>

                <div class="w-full text-center mb-3">Importance</div>
            </div>
            <NuxtLink class="p-7 link" :class="{ 'text-gray-500': weight >= 5 }" @click="weight = Math.min(5, weight + 1)">
                <Icon name="ph:plus-circle" size="2em" />
            </NuxtLink>
        </div>

        <div class="flex flex-row place-content-evenly">
            <Btn width="w-32" :class="{ 'btn-disabled': (question.length <= 10 || loading) }">No</Btn>
            <Btn width="w-32">Yes</Btn>
        </div>
        <div class="flex flex-row place-content-evenly">
            <Btn width="w-72">Publish</Btn>
        </div>
    </div>
    <div class="grow w-full rounded-b-xl" :class="colors[color].color" />
</template>
