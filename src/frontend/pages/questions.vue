<script lang="ts" setup>
import { AppState, inBrowser, useAppState } from '~/composables/appState';

definePageMeta({ title: "Project design" });

const app = useAppState();

if (inBrowser()) {
    app.getTeam();
    app.loadQuestions(0);
    app.loadUser();
    app.loadTeams();
}
</script>


<template>
    <AllkindsTitle link-to="/welcome">
        {{ app.checkTeam() }}
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
        <Question v-for="(q, _) in app.getOpenQuestions().data" :question="q" :link="true" />

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