<script lang="ts" setup>

definePageMeta({
    title: "Allkinds",
    layout: 'default'
});

const app = useAppState();
const user = () => app.getUser().data?.user;

if (inBrowser()) {
    app.getTeam();
    app.loadOpenQuestions(0);
    app.loadUser();
    app.loadTeams();
}
</script>


<template>
    <div class="w-full flex-grow flex flex-col">
        <AllkindsTitle link-to="/team-stats" :logo-url="toDataUrl(app.getTeam()?.info.logo || [])">
            {{ app.checkTeam() }}
            <NuxtLink to="/my-profile" class="m-auto">
                {{ user()?.displayName }}, {{ user()?.stats.points }}
                <Icon name="gg:shape-hexagon" class="mb-2" />
            </NuxtLink>

            <template #action>
                <NuxtLink to="/contacts" slot="action">
                    <Icon name="prime:users" size="2em" />
                </NuxtLink>
            </template>
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
                    <Btn @click="app.loadOpenQuestions(0, 'Questions loaded')">
                        Reload &nbsp;
                        <Icon name="charm:refresh" />
                    </Btn>
                </div>
                <div class="grow" />
            </div>
        </NetworkDataContainer>
    </div>
</template>