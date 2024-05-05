<script lang="ts" setup>
import type { FriendStatus, UserMatch } from '../../utils/backend';

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
        navTo("/discover");
    } else {
        u = data.find((x) => x.user.username === username) as UserMatch | null;
        if (!u) {
            console.warn("user not found in matches", username, data);
            navTo("/discover");
        }
    }

    return u;
}

const m = (): UserMatch => findUser(route.params.username + "") || ({ user: {}, answered: [], uncommon: [] } as unknown as UserMatch);

const connect = (username: string) => {
    navTo("/contacts")
    app.sendFriendRequest(username).then(
        () => { app.loadFriends(0) }
    )
}

if (inBrowser()) {
    app.getTeam();
    app.loadUser();
    app.loadMatches();
}

let dotmenu = ref(false);
let filter = ref("all");

</script>

<template>
    <div class="w-full flex-grow flex flex-col">

        <AllkindsTitle class="w-full" logo="x" linkTo="/discover">
            <span />
            <template #action>
                <div v-if="dotmenu" class="fixed inset-0 bg-black bg-opacity-30 backdrop-blur-sm"></div>
                <div class="relative">
                    <button class="hover:invert bg-black rounded-full p-2" @click="dotmenu = !dotmenu">
                        <Icon name="ph:dots-three-outline-duotone" size="1.5em"/>
                    </button>
                    <div v-if="dotmenu" class="absolute right-0 z-10 bg-black rounded-lg px-5 flex flex-col items-center space-y-5 py-5">
                        <Btn @click="connect(m().user.username)" class="w-72">
                            Connect <IconFor logo="user-add" size="1.6em" />
                        </Btn>
                    </div>
                </div>
            </template>
        </AllkindsTitle>


        <div class="p-3 w-full flex flex-col">
            <div class="grid grid-cols-2 gap-4">
                <div class="text-3xl font-bold">
                    {{ m().user.displayName }}
                </div>
                <div class="text-3xl font-bold flex flex-row align-top">
                    <div class="mr-4">{{ m().cohesion }}%</div>
                    <div class="text-xl mt-[-5px] font-bold flex flex-row">
                        <div><IconFor logo="star" class="text-amber-300" /></div>
                        <div><IconFor logo="star" class="text-amber-300" /></div>
                        <div><IconFor logo="star" class="text-amber-300" /></div>
                        <div><IconFor logo="star-empty" /></div>
                    </div>
                </div>
                <div class="whitespace-pre-wrap font-normal">
                    {{ m().user.about }}
                </div>
                <div class="font-normal">
                    <span class="text-green-500 font-bold">{{m().answered.filter(([q, diff]) => diff.sameAnswer).length }}</span> same answers from <br>
                    {{ m().answered.length }} questions
                </div>
            </div>
            <Btn class="place-self-center mt-8 mb-5" @click="connect(m().user.username)" >
                Connect
                <Icon name="prime:user-plus" size="1.5em" />
            </Btn>
            <!-- Filter bar -->
            <div class="flex flex-row space-x-4">
                <BtnSmall class="grow" :class="{ 'bg-white text-black': filter==='all'}" @click="filter='all'">All</BtnSmall>
                <BtnSmall class="grow" :class="{ 'bg-white text-black': filter==='same'}" @click="filter='same'">Same</BtnSmall>
                <BtnSmall class="grow" :class="{ 'bg-white text-black': filter==='unanswered'}" @click="filter='unanswered'">Unanswered</BtnSmall>
            </div>
        </div>


        <div v-if="filter === 'all' || filter === 'same'" v-for="[q, diff] in m().answered.filter(([q, diff]) => diff.sameAnswer)">
            <Question :question="q" class="blur-lg" />
        </div>

        <Question v-if="filter === 'all' || filter === 'unanswered'" v-for="(q, i) in m().uncommon" :question="q" :link="true" />

        <div class="p-12">
        </div>
    </div>
</template>
