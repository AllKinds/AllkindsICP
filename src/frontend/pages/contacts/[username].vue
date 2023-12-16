<script lang="ts" setup>
import { FriendStatus, UserMatch } from '../../utils/backend';


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
        navigateTo("/contacts");
    } else {
        u = data.find((x) => x[0].user.username === username) as [UserMatch, FriendStatus] | null;
        if (!u) {
            console.warn("user not found in matches", username, data);
            navigateTo("/contacts");
        }
    }

    return u;
}

const m = () => findUser(route.params.username + "") || ([{ user: {}, answered: [], uncommon: [] }, {}] as unknown as [UserMatch, FriendStatus]);

const connect = (username: string) => {
    navigateTo("/contacts")
    app.sendFriendRequest(username).then(
        () => { app.loadFriends(0) }
    )
}

const disconnect = (username: string) => {
    navigateTo("/contacts")
    app.answerFriendRequest(username, false).then(
        () => { app.loadFriends(0) }
    )
}

if (inBrowser()) {
    app.loadFriends(0);
}

let diff = {}

</script>

<template>
    <AllkindsTitle class="w-full" logo="ph:x-circle" linkTo="/contacts">
    </AllkindsTitle>

    <div class="p-3 w-full">
        <NuxtLink class="float-right" @click="connect(m()[0].user.username)" v-if="canSendFriendRequest(m()[1])">
            <Icon name="prime:user-plus" size="3em" />
        </NuxtLink>
        <NuxtLink class="float-right" @click="disconnect(m()[0].user.username)" v-if="canSendRemoveFriendRequest(m()[1])">
            <Icon name="prime:user-minus" size="3em" />
        </NuxtLink>
        <div class="text-xl font-bold">
            {{ m()[0].user.displayName }} ({{ formatFriendStatus(m()[1]) }})
        </div>
        <div>
            Cohesion score: {{ m()[0].cohesion }}% on {{ m()[0].answered.length }} questions
        </div>
    </div>

    <div v-for="[q, diff] in m()[0].answered" :class="getColor(diff.sameAnswer ? 'green' : 'black').color"
        class="w-full p-4 rounded-md m-1" v-if="true">
        {{ q.question }}
    </div>


    <NuxtLink v-for="(q, i) in m()[0].uncommon" :question="q" :to="'/answer-question/' + q.id"
        :class="getColor(q.color as ColorName).color" class="border p-4 w-full my-2 rounded-lg block text-2xl font-medium">
        <Icon name="material-symbols:arrow-forward-ios" class="float-right mt-1" />
        {{ q.question }}
    </NuxtLink>

    <div class="p-12">
    </div>
</template>
