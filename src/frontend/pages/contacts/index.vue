<script lang="ts" setup>
import { Effect } from 'effect';

definePageMeta({ title: "Contacts" });

const app = useAppState();


if (inBrowser()) {
    app.getTeam();
    app.loadUser();
    app.loadFriends(0);
}

let match = { user: { username: "" } };
</script>


<template>
    <div class="w-full flex-grow flex flex-col">
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

            <NuxtLink v-for="[match, status] in app.getFriends().data?.slice().reverse()"
                :to="'/contacts/' + match.user.username" class="flex flex-row w-full text-xl font-bold">
                <div class="m-2">
                    {{ match.user.username }}:
                </div>
                <div class="m-2 flex-grow">
                    {{ match.cohesion }}%
                    ({{ match.answered.length }})
                </div>
                <div class="m-2 font-normal text-gray-500">
                    ({{ formatFriendStatus(status) }})
                </div>
                <div class="m-2">
                    <Icon :name="friendStatusIcon(status).icon" size="1.5em" :class="friendStatusIcon(status).color" />
                </div>
            </NuxtLink>
        </NetworkDataContainer>
    </div>
</template>