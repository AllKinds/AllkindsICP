<script lang="ts" setup>
import type { TeamUserInfo } from '~/utils/backend';

definePageMeta({
    title: "Allkinds",
    layout: 'default'
});
const app = useAppState();

if (inBrowser()) {
    app.getTeam(false);
    app.loadTeams(0);
    app.loadUser(undefined, false);
}

let gotoInfo = false;

const setTeam = (t: TeamUserInfo) => {
    app.setTeam(t.key);
    if (gotoInfo) {
        navTo("/team-info")
    } else if (t.permissions.isMember) {
        navTo("/team-info")
    } else {
        navTo("/join/" + t.key)
    }
}

const canCreate = () => {
    const u = app.getUser();
    if (u.status !== 'ok') return false;
    return u.data?.permissions.createTeam;
}

const notifications = (team: string): bigint => {
    const ns = app.getUser().data?.notifications;
    if (!ns) return 0n;
    let count = 0n;
    for (let n of ns) {
        if (n.team.indexOf(team) >= 0) {
            if ("chat" in n.event) {
                count += Object.values(n.event)[0].unread;
            } else {
                count += Object.values(n.event)[0];
            }
        }
    }
    console.log("notifications", ns);
    return count;
}


</script>

<template>
    <div class="w-full flex-grow flex flex-col items-center">
        <AllkindsTitle class="py-16" />
        <h1 class="text-center max-w-sm">
            We see the world with more meaningful connections.
        </h1>

        <NetworkDataContainer :networkdata="app.getTeams()" class="w-full text-lg text-center mt-10">
            <div class="w-full text-center mb-8">
                Available teams: {{ app.getTeams().data?.length }}
            </div>

            <Btn v-if="canCreate()" to="/create-team" class="w-72 mb-10">Create a new team</Btn>

            <div v-for="t in app.getTeams().data" @click="setTeam(t)"
                class="border border-white p-4 rounded-lg my-2 w-full cursor-pointer flex ">
                <div>
                    <img :src="toDataUrl(t.info.logo)" height="100" width="100" class="rounded-md" />
                </div>
                <div class="w-full pl-4">

                    <span v-if="notifications(t.key)" class="float-right text-sm text-red-600 px-1">{{
            notifications(t.key) }}</span>

                    <!--NuxtLink to="/team-info" @click="gotoInfo = true">
                        <Icon name="tabler:info-hexagon" size="2em" class="float-right text-white" />
                    </NuxtLink-->
                    <Icon v-if="t.permissions.isAdmin" name="tabler:user-shield" size="2em"
                        class="float-right text-green-600" />
                    <Icon v-if="t.permissions.isMember" name="tabler:user-check" size="2em"
                        class="float-right text-green-600" />
                    <div class="text-2xl">
                        {{ t.info.name }}
                    </div>
                    <p class="whitespace-pre-wrap">
                        {{ t.info.about }}
                    </p>
                </div>
            </div>
        </NetworkDataContainer>

        <div class="w-full flex-grow" />
    </div>
</template>
