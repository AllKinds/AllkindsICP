<script lang="ts" setup>
definePageMeta({
    title: "Contacts",
    layout: 'default'
});
import type { FriendStatus, UserMatch } from '../../utils/backend';


const route = useRoute();
const app = useAppState();


let loaded = false;

function findUser(username: string): [UserMatch, FriendStatus] | null {
    const data = app.friends.data;
    let u = null;
    if (!data || app.friends.status === "requested") {
        if (!loaded) {
            loaded = true;
            app.loadMatches();
        }
    } else if (data.length === 0) {
        console.warn("no user in matches");
        navTo("/contacts");
    } else {
        u = data.find((x) => x[0].user.username === username) as [UserMatch, FriendStatus] | null;
        if (!u) {
            console.warn("user not found in matches", username, data);
            navTo("/contacts");
        }
    }

    return u;
}

const m = () => findUser(route.params.username + "") || ([{ user: {}, answered: [], uncommon: [] }, {}] as unknown as [UserMatch, FriendStatus]);

const connect = (username: string) => {
    navTo("/contacts")
    app.sendFriendRequest(username).then(
        () => { app.loadFriends(0) }
    )
}

const disconnect = (username: string) => {
    navTo("/contacts")
    app.answerFriendRequest(username, false).then(
        () => { app.loadFriends(0) }
    )
}

if (inBrowser()) {
    app.getTeam();
    app.loadFriends(0);
}

let diff = {}

</script>

<template>
    <div class="w-full flex-grow flex flex-col">
        <AllkindsTitle class="w-full" logo="x" linkTo="/contacts">
            <span />
        </AllkindsTitle>

        <div class="p-3 w-full">
            <NuxtLink class="float-right cursor-pointer" @click="connect(m()[0].user.username)"
                v-if="canSendFriendRequest(m()[1])">
                <Icon name="prime:user-plus" size="3em" />
            </NuxtLink>
            <NuxtLink class="float-right cursor-pointer" @click="disconnect(m()[0].user.username)"
                v-if="canSendRemoveFriendRequest(m()[1])">
                <Icon name="prime:user-minus" size="3em" />
            </NuxtLink>
            <div class="text-xl font-bold">
                {{ m()[0].user.displayName }} ({{ formatFriendStatus(m()[1]) }})
            </div>
            <div>
                Cohesion score: {{ m()[0].cohesion }}% on {{ m()[0].answered.length }} questions
            </div>
            <div v-if="friendStatusToKey(m()[1]) === 'connected'">
                Contact: {{ m()[0].user.contact }}
            </div>
        </div>

        <Question v-for="[q, diff] in m()[0].answered" :question="q" :color="diff.sameAnswer ? 'green' : 'black'" />

        <Question v-for="(q, i) in m()[0].uncommon" :question="q" :link="true" />

        <div class="p-12">
        </div>
    </div>
</template>
