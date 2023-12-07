<script lang="ts" setup>
import { Effect } from 'effect';

definePageMeta({ title: "Contacts" });

const app = useAppState();


if (inBrowser()) {
    app.loadUser();
    app.loadFriends();
}
</script>


<template>
    <AllkindsTitle logo="ph:x-circle" logoSize="2em" linkTo="/questions">
        <NuxtLink to="/my-profile" class="m-auto">
            {{ app.getUser().username }}, {{ app.getUser().points }}
            <Icon name="gg:shape-hexagon" class="mb-2" />
        </NuxtLink>

        <NuxtLink to="/contacts">
            <Icon name="prime:users" size="2em" />
        </NuxtLink>
    </AllkindsTitle>

    <NetworkDataContainer :networkdata="app.getFriends()">
        <div v-if="app.getFriends().data?.length === 0">
            You have no connections yet. <!-- TODO: add instructions to find friends -->
        </div>

        <div v-for="[match, status] in app.getFriends().data">
            {{ match.user.username }}: {{ match.cohesion }} ({{ formatFriendStatus(status) }})
        </div>
    </NetworkDataContainer>
</template>