<script lang="ts" setup>
definePageMeta({
    title: "About",
    layout: 'default'
});

import { createQuestion } from "../utils/backend"
import { getColor } from "../utils/color";

const question = useState('new-question', () => "")
const app = useAppState();
const loading = useState("loading", () => false);
const color = useState<ColorName>('color', () => "green")
const weight = useState('weight', () => 1)


// TODO: move to app
async function create() {
    loading.value = true;

    await runNotify(createQuestion(app.team, question.value, color.value as ColorName), "Question created successfully.").then(
        () => {
            question.value = "";
            loading.value = false;
            app.loadQuestions(0);
        }
    );
}

function canCreate() {
    return question.value.length >= 10 && !loading.value
}

if (inBrowser()) {
    app.getTeam()
    app.loadUser();
}

</script>

<template>
    <div class="w-full flex-grow flex flex-col">
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
            <TextArea :min-height="30" @ctrl-enter="create" v-model="question" placeholder="Ask a Yes/No question…"
                :class="[{ 'input-disabled': loading }, getColor(color).color]" />
        </div>

        <div class="grow w-full" :class="getColor(color).color" />
        <div class="grow w-full" :class="getColor(color).color" />

        <div class="w-full" :class="getColor(color).color">
            <ColorPicker v-model="color" />
            <!--
           <Importance v-model="weight" />

            <div class="flex flex-row place-content-evenly">
                <Btn width="w-32" :disabled="!canCreate()" @click="create">No</Btn>
                <Btn width="w-32" :disabled="!canCreate()" @click="create">Yes</Btn>
            </div>
        -->
            <div class="flex flex-row place-content-evenly mt-20">
                <Btn width="w-72" :disabled="!canCreate()" @click="create">Publish</Btn>
            </div>
        </div>
        <div class="grow w-full rounded-b-xl" :class="getColor(color).color" />
    </div>
</template>
