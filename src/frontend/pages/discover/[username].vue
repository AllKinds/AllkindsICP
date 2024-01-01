<script lang="ts" setup>
import { UserMatch } from '../../utils/backend';

definePageMeta({
    title: "Contacts",
    layout: 'default'
});

const route = useRoute();
const app = useAppState();


let loaded = false;

function findUser(username: string): UserMatch | null {
    const data = app.matches.data;
    let u = null;
    if (!data) {
        if (!loaded) {
            loaded = true;
            app.loadMatches();
        }
    } else if (data.length === 0) {
        console.warn("no user in matches");
        navigateTo("/discover");
    } else {
        u = data.find((x) => x.user.username === username) as UserMatch | null;
        if (!u) {
            console.warn("user not found in matches", username, data);
            navigateTo("/discover");
        }
    }

    return u;
}

const m = (): UserMatch => findUser(route.params.username + "") || ({ user: {}, answered: [], uncommon: [] } as unknown as UserMatch);

const connect = (username: string) => {
    navigateTo("/contacts")
    app.sendFriendRequest(username).then(
        () => { app.loadFriends(0) }
    )
}

if (inBrowser()) {
    app.getTeam();
    app.loadUser();
    app.loadMatches();
}

let diff = {}

</script>

<template>
    <div class="w-full flex-grow flex flex-col">
        <AllkindsTitle class="w-full" logo="ph:x-circle" linkTo="/discover">
        </AllkindsTitle>

        <div class="p-3 w-full">
            <NuxtLink class="float-right cursor-pointer" @click="connect(m().user.username)">
                <Icon name="prime:user-plus" size="3em" />
            </NuxtLink>
            <div class="text-xl font-bold">
                {{ m().user.displayName }}
            </div>
            <div>
                Cohesion score: {{ m().cohesion }}% on {{ m().answered.length }} questions
            </div>
        </div>

        <Question v-for="[q, diff] in m().answered" :question="q" :color="diff.sameAnswer ? 'green' : 'black'" />

        <Question v-for="(q, i) in m().uncommon" :question="q" :link="true" />

        <div class="p-12">
        </div>
    </div>
</template>
