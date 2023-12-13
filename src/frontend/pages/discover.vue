<script lang="ts" setup>
import { Effect } from 'effect';

definePageMeta({ title: "Contacts" });

const app = useAppState();


if (inBrowser()) {
    app.loadUser();
    app.loadMatches();
}
</script>


<template>
    <AllkindsTitle logo="ph:x-circle" logoSize="2em" linkTo="/questions">
        <NuxtLink to="/my-profile" class="m-auto">
            {{ app.getUser().displayName }}, {{ app.getUser().stats.points }}
            <Icon name="gg:shape-hexagon" class="mb-2" />
        </NuxtLink>

    </AllkindsTitle>

    <NetworkDataContainer :networkdata="app.getMatches()" class="w-96">
        <div v-if="app.getMatches().data?.length === 0">
            No matches found.
            <br>
            You need at least 5 questions in common to see each others coherence score.
        </div>

        <div v-for="match in app.getMatches().data" class="text-xl flex flex-row w-full p-3">
            <div class="flex-grow">{{ match.user.displayName }}</div>
            <div>{{ match.cohesion }} ({{ match.answered.length }})</div>
        </div>
    </NetworkDataContainer>
</template>