<script lang="ts" setup>
import { User, UserMatch } from '~/utils/backend';


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
    app.sendFriendRequest(username).then(
        () => { navigateTo("/contacts") }
    )
}

if (inBrowser()) {
    app.loadUser();
}

let diff = {}

</script>

<template>
    <AllkindsTitle class="w-full" logo="ph:x-circle" linkTo="/discover">
    </AllkindsTitle>

    <div class="p-3 w-full">
        <NuxtLink class="float-right" @click="connect(m().user.username)">
            <Icon name="prime:user-plus" size="3em" />
        </NuxtLink>
        <div class="text-xl font-bold">
            {{ m().user.displayName }}
        </div>
        <div>
            Cohesion score: {{ m().cohesion }}% on {{ m().answered.length }} questions
        </div>
    </div>

    <div v-for="[q, diff] in m().answered" :class="getColor(diff.sameAnswer ? 'green' : 'black').color"
        class="w-full p-4 rounded-md m-1" v-if="true">
        {{ q.question }}
    </div>


    <NuxtLink v-for="(q, i) in m().uncommon" :question="q" :to="'/answer-question/' + q.id"
        :class="getColor(q.color as ColorName).color" class="border p-4 w-full my-2 rounded-lg block text-2xl font-medium">
        <Icon name="material-symbols:arrow-forward-ios" class="float-right mt-1" />
        {{ q.question }}
    </NuxtLink>

    <div class="p-12">
    </div>
</template>
