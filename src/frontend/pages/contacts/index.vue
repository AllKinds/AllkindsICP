<script lang="ts" setup>
import { Effect } from 'effect';

definePageMeta({ title: "Contacts" });

const app = useAppState();


if (inBrowser()) {
    app.loadUser();
    app.loadFriends(0);
}
</script>


<template>
    <AllkindsTitle logo="ph:x-circle" logoSize="2em" linkTo="/questions">
        <NuxtLink to="/my-profile" class="m-auto">
            {{ app.getUser().displayName }}, {{ app.getUser().stats.points }}
            <Icon name="gg:shape-hexagon" class="mb-2" />
        </NuxtLink>

        <NuxtLink to="/discover">
            <Icon name="prime:user-plus" size="2em" />
        </NuxtLink>

    </AllkindsTitle>

    <NetworkDataContainer :networkdata="app.getFriends()" class="w-full">
        <div v-if="app.getFriends().data?.length === 0">
            You have no connections yet. <!-- TODO: add instructions to find friends -->
        </div>

        <NuxtLink v-for="[match, status] in app.getFriends().data" :to="'/contacts/' + match.user.username"
            class="flex flex-row w-full">
            <div class="flex-grow m-2">
                {{ match.user.username }}:
            </div>
            <div class="m-2">
                {{ match.cohesion }} %
                ({{ match.answered.length }})
            </div>
            <div class="m-2">
                ({{ formatFriendStatus(status) }})
            </div>
        </NuxtLink>
    </NetworkDataContainer>
</template>