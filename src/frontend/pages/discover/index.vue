<script lang="ts" setup>
definePageMeta({
    title: "Contacts",
    layout: 'default'
});

const app = useAppState();
const user = () => app.getUser().data?.user;

if (inBrowser()) {
    app.getTeam();
    app.loadUser();
    app.loadMatches();
}
</script>


<template>
    <div class="w-full flex-grow flex flex-col items-center">
        <AllkindsTitle logoSize="2em" linkTo="/questions">
            <NuxtLink to="/my-profile" class="m-auto">
                {{ user()?.displayName }}, {{ user()?.stats.points }}
                <Icon name="gg:shape-hexagon" class="mb-2" />
            </NuxtLink>

            <template #action>
                <IconLink to="/contacts" />
            </template>

        </AllkindsTitle>

        <NetworkDataContainer :networkdata="app.getMatches()" class="w-96 pb-32">
            <div v-if="app.getMatches().data?.length === 0">
                No matches found.
                <br>
                You need at least 5 questions in common to see each others coherence score.
            </div>

            <NuxtLink v-for="match in app.getMatches().data" :to="'/discover/' + match.user.username"
                class="text-xl font-bold flex flex-row w-full p-3">
                <div class="flex-grow">{{ match.user.displayName }}</div>
                <div>{{ match.cohesion }}% <span class="">({{ match.answered.length }})</span></div>
            </NuxtLink>
        </NetworkDataContainer>
    </div>
</template>