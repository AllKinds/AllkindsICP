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

    <NetworkDataContainer :networkdata="app.getMatches()">
        <div v-if="app.getMatches().data?.length === 0">
            No matches found.
            <br>
            You need at least 5 questions in common to see each others coherence score.
        </div>

        <div v-for="match in app.getMatches().data">
            {{ match.user.username }}: {{ match.cohesion }} ({{ match.answered.length }})
        </div>
    </NetworkDataContainer>
</template>