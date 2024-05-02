<script lang="ts" setup>
import { createQuestion } from "../utils/backend"
import { getColor } from "../utils/color";

definePageMeta({
    title: "About",
    layout: 'default',
});

const question = useState('new-question', () => "")
const app = useAppState();
const loading = useState("loading", () => false);
const color = useState<ColorName>('color', () => "green")
const weight = useState('weight', () => 1)


// TODO: move to app
async function create() {
    if (question.value.length < 10) return;
    loading.value = true;

    await runNotify(createQuestion(app.team, question.value, color.value as ColorName), "Question created successfully.").then(
        () => {
            question.value = "";
            loading.value = false;
            app.loadOpenQuestions(0);
        }
    );
}

function canCreate() {
    return question.value.length >= 10 && !loading.value
}

const user = () => app.getUser().data?.user;

if (inBrowser()) {
    app.getTeam();
    app.loadUser();
    setTimeout(
        () => window.document.getElementsByTagName("textarea")[0]?.focus(), 400
    );
}

</script>

<template>
    <div class="w-full flex-grow flex flex-col">
        <AllkindsTitle class="w-full" logo="x" link-to="/questions">
            <NuxtLink to="/my-profile" class="border-b-2">
                {{ user()?.displayName }}, {{ user()?.stats.points }}
                <Icon name="gg:shape-hexagon" class="mb-2" />
            </NuxtLink>

            <template #action>
                <IconLink to="/discover" class="border-solid border-white" />
            </template>
        </AllkindsTitle>

        <div class="grow w-full h-3 rounded-t-xl" :class="getColor(color).color" />

        <div class="p-5 w-full max-w-xl" :class="getColor(color).color">
            <div v-if="loading" class="text-center w-full">
                <Icon name="line-md:loading-alt-loop" size="5em" class="absolute mt-8" style="margin-left: -2.5em;" />
            </div>
            <TextArea :min-height="30" @ctrl-enter="create" v-model="question" placeholder="Ask a Yes/No question…"
                :class="[{ 'input-disabled': loading }, getColor(color).color]" class="text-3xl" />
        </div>

        <div class="grow w-full" :class="getColor(color).color" />
        <div class="grow w-full" :class="getColor(color).color" />

        <div class="w-full" :class="getColor(color).color">
            <ColorPicker v-model="color" />
            <div class="flex flex-row place-content-evenly mt-20">
                <Btn width="w-72" :disabled="!canCreate()" @click="create">Publish</Btn>
            </div>
        </div>
        <div class="grow w-full h-3 rounded-b-xl" :class="getColor(color).color" />
    </div>
</template>
