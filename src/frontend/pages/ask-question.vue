<script lang="ts" setup>
import { Effect } from "effect";
import { loadQuestions, createQuestion } from "~/utils/backend"
import { getColor } from "~/utils/color";

const question = useState('new-question', () => "")
const app = useAppState();
const loading = useState("loading", () => false);
const color = useState<ColorName>('color', () => "green")
const weight = useState('weight', () => 1)

async function loadQs() {
    app.loadQuestions(0)
}

async function create() {
    loading.value = true;

    await runNotify(createQuestion(question.value, color.value as ColorName), "Question created successfully.").then(
        () => {
            question.value = "";
            loading.value = false;
            return loadQs();
        }
    );
}

function canCreate() {
    return question.value.length >= 10 && !loading.value
}

if (inBrowser()) {
    app.loadUser();
}

</script>

<template>
    <AllkindsTitle class="w-full" logo="ph:x-circle" link-to="/questions">
        <NuxtLink to="/my-profile" class="m-auto">
            {{ app.getUser().displayName }}, {{ app.getUser().stats.points }}
            <Icon name="gg:shape-hexagon" class="mb-2" />
        </NuxtLink>

        <Icon name="prime:users" size="2em" />
    </AllkindsTitle>

    <div class="grow w-full rounded-t-xl" :class="getColor(color).color" />

    <div class="p-5 w-full max-w-xl" :class="getColor(color).color">
        <div v-if="loading" class="text-center w-full">
            <Icon name="line-md:loading-alt-loop" size="5em" class="absolute mt-8" style="margin-left: -2.5em;" />
        </div>
        <TextArea style="min-height: 1em !important" @ctrl-enter="create" v-model="question"
            placeholder="Ask a Yes/No question…" :class="[{ 'input-disabled': loading }, getColor(color).color]" />
    </div>

    <div class="grow w-full" :class="getColor(color).color" />
    <div class="grow w-full" :class="getColor(color).color" />

    <div class="w-full" :class="getColor(color).color">
        <ColorPicker v-model="color" />

        <div class="w-full mt-3 flex flex-row place-content-evenly">
            <NuxtLink class="p-7 link" :class="{ 'text-gray-500 pointer-events-none': weight <= 1 }"
                @click="weight = Math.max(1, weight - 1)">
                <Icon name="ph:minus-circle" size="2em" />
            </NuxtLink>
            <div class="text-center relative">
                <Icon name="gg:shape-hexagon" size="5em" />
                <div class="absolute top-7 w-full text-center">+{{ weight }}</div>

                <div class="w-full text-center mb-3">Importance</div>
            </div>
            <NuxtLink class="p-7 link" :class="{ 'text-gray-500 pointer-events-none': weight >= 5 }"
                @click="weight = Math.min(5, weight + 1)">
                <Icon name="ph:plus-circle" size="2em" />
            </NuxtLink>
        </div>

        <div class="flex flex-row place-content-evenly">
            <Btn width="w-32" :disabled="!canCreate()" @click="create">No</Btn>
            <Btn width="w-32" :disabled="!canCreate()" @click="create">Yes</Btn>
        </div>
        <div class="flex flex-row place-content-evenly">
            <Btn width="w-72" :disabled="!canCreate()" @click="create">Publish</Btn>
        </div>
    </div>
    <div class="grow w-full rounded-b-xl" :class="getColor(color).color" />
</template>
