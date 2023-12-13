<script lang="ts" setup>
definePageMeta({ title: "Project design" });

import { loadQuestions, createQuestion } from "~/utils/backend"
import { getColor } from "~/utils/color"

const question = useState('new-question', () => "")
const app = useAppState();
const loading = useState("loading", () => false);


async function create() {
    loading.value = true;
    const q = question.value;

    await runNotify(createQuestion(q, "black"), "Question created successfully.").then(
        () => {
            question.value = "";
            loading.value = false;
            app.loadQuestions(0);
        }
    );
}

if (inBrowser()) {
    app.loadQuestions();
    app.loadUser()
} else {
    //app.openQuestions.status = "init";
}
</script>


<template>
    <AllkindsTitle>
        <NuxtLink to="/my-profile" class="m-auto">
            {{ app.getUser().displayName }}, {{ app.getUser().stats.points }}
            <Icon name="gg:shape-hexagon" class="mb-2" />
        </NuxtLink>

        <NuxtLink to="/contacts">
            <Icon name="prime:users" size="2em" />
        </NuxtLink>
    </AllkindsTitle>

    <NuxtLink to="/ask-question" class="w-full rounded bg-slate-100 text-gray-500 text-xl p-5 cursor-text">
        Ask your yes/no question
    </NuxtLink>

    <NetworkDataContainer :networkdata="app.getOpenQuestions()" class="grow mt-4 w-full">
        <NuxtLink v-for="(q, i) in app.getOpenQuestions().data" :question="q" :selected="i === 0"
            :to="'/answer-question/' + q.id" :class="getColor(q.color as ColorName).color"
            class="border p-4 w-full my-2 rounded-lg block text-2xl font-medium">
            <Icon name="material-symbols:arrow-forward-ios" class="float-right mt-1" />
            {{ q.question }}
        </NuxtLink>
        <div v-if="app.getOpenQuestions().data?.length === 0">
            There are no more questions at the moment.

            <p>
                Ask one above or check back later.
            </p>

            <div class="grow" />
            <div class="w-full text-center my-10">
                <Btn @click="app.loadQuestions(0, 'Questions loaded')">
                    Reload &nbsp;
                    <Icon name="charm:refresh" />
                </Btn>
            </div>
            <div class="grow" />
        </div>
    </NetworkDataContainer>
</template>