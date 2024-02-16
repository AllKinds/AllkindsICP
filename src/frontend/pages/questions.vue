<script lang="ts" setup>
import NumberAnimation from 'vue-number-animation';

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
const balance = ref<any>(null);
setTimeout(() => balance.value?.restart(), 300)
</script>


<template>
    <div class="w-full flex-grow flex flex-col">
        <AllkindsTitle link-to="/team-stats" :logo-url="toDataUrl(app.getTeam()?.info.logo || [])">
            {{ app.checkTeam() }}
            <NuxtLink to="/my-profile" class="m-auto">
                {{ user()?.displayName }},
                <NumberAnimation :to="user()?.stats.points" :from=0 ref="balance" duration=0.3 autoplay easing="linear"
                    :format="Math.round" />
                <Icon name="gg:shape-hexagon" class="mb-2" />
            </NuxtLink>

            <template #action>
                <IconLink to="/discover" />
            </template>
        </AllkindsTitle>

        <Btn to="/ask-question" class="w-96 m-5 self-center">
            Ask your yes/no question
        </Btn>

        <NetworkDataContainer :networkdata="app.getOpenQuestions()" class="grow mt-4 w-full">
            <Question v-for="( q, _ ) in  app.getOpenQuestions().data " :question="q" :link="true" />

            <div v-if="app.getOpenQuestions().data?.length === 0">
                There are no more questions at the moment.

                <p>
                    Ask one above or check back later.
                </p>

                <div class="grow" />
                <div class="w-full text-center my-10">
                    <Btn @click="app.loadOpenQuestions(0, 'Questions loaded')">
                        Refresh &nbsp;
                        <Icon name="charm:refresh" />
                    </Btn>
                </div>
                <div class="grow" />
            </div>
        </NetworkDataContainer>
    </div>
</template>
