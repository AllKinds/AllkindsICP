<script lang="ts" setup>

definePageMeta({
    title: "Contacts",
    footerMenu: true,
});

const app = useAppState();


if (inBrowser()) {
    app.getTeam();
    app.loadUser();
    app.loadFriends(0);
}

const user = () => app.getUser().data?.user;

let match = { user: { username: "" } };
</script>


<template>
    <div class="w-full flex-grow flex flex-col">
        <AllkindsTitle>
            <NuxtLink to="/my-profile">
                {{ user()?.displayName }}, {{ user()?.stats.points }}
                <Icon name="gg:shape-hexagon" class="mb-2" />
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