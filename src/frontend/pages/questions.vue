<script lang="ts" setup>
// @ts-ignore ts(7016)
import NumberAnimation from 'vue-number-animation';

definePageMeta({
    title: "Allkinds",
    layout: 'default',
    footerMenu: true,
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
            <NuxtLink to="/my-profile">
                {{ user()?.displayName }},
                <NumberAnimation :to="user()?.stats.points" :from=0 ref="balance" :duration="0.3" autoplay easing="linear"
                    :format="Math.round" />
                <Icon name="gg:shape-hexagon" class="mb-2" />
            </NuxtLink>
        </AllkindsTitle>

        <div class="w-full flex-grow flex flex-col  overflow-y-auto h-72 scrollbar-none rounded-lg">

            <Btn to="/ask-question" class="w-72 my-5 self-center">
                Ask&nbsp;your&nbsp;yes/no&nbsp;question
            </Btn>

            <NetworkDataContainer :networkdata="app.getOpenQuestions()" class="grow mt-4 w-full">
                <Question v-for="( q, _ ) in  app.getOpenQuestions().data " :question="q" :link="true" />

                <div v-if="app.getOpenQuestions().data?.length === 0" class="text-center text-xl my-16">
                    There are no more questions at the moment.

                    <p>
                        <br>
                        Ask one above or check back later.
                    </p>

                    <div class="grow" />
                    <div class="w-full text-center my-16">
                        <Btn @click="app.loadOpenQuestions(0, 'Questions loaded')">
                            Refresh &nbsp;
                            <Icon name="charm:refresh" />
                        </Btn>
                    </div>
                    <div class="grow" />
                </div>
            </NetworkDataContainer>
        </div>

    </div>
</template>
