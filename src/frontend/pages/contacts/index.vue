<script lang="ts" setup>
import type { FriendStatus } from "~/utils/backend";
import { formatDate } from "../../utils/utils";

definePageMeta({
    title: "Contacts",
    footerMenu: true,
});

const app = useAppState();


if (inBrowser()) {
    app.getTeam();
    app.loadUser(0);
    app.loadFriends(0);
}

const user = () => app.getUser().data?.user;
const getMessage = (other: string) => {
    const notifications = app.getUser().data?.notifications;
    if (!notifications) return undefined;
    const n = notifications.find((n) => "chat" in n.event && n.event.chat.user === other);
    if (!n || !("chat" in n.event)) return undefined;
    return n.event.chat;
};

let match = { user: { username: "" } };
match = match;

const linkUser = (username: string, status : FriendStatus) => {
    const key = friendStatusToKey(status);
    if (key === "connected") {
        return '/chat/' + username;
    }
    return '/contacts/' + username;
}
</script>


<template>
    <div class="w-full flex-grow flex flex-col">
        <AllkindsTitle>
            <NuxtLink to="/my-profile">
                {{ user()?.displayName }}, {{ user()?.stats.points }}
                <Icon name="gg:shape-hexagon" class="mb-2" />
            </NuxtLink>
        </AllkindsTitle>

        <NetworkDataContainer :networkdata="app.getFriends()" class="w-full flex flex-col space-y-8">
            <div v-if="app.getFriends().data?.length === 0">
                You have no connections yet.
            </div>

            <NuxtLink v-for="[match, status] in app.getFriends().data?.slice().reverse()"
                :to="linkUser(match.user.username, status)" class="w-full text-xl font-bold">
                <div class="flex flex-row w-full space-x-2">
                    <div>
                        {{ match.user.username }}:
                    </div>
                    <div class="flex-grow">
                        {{ match.cohesion }}%
                        ({{ match.answered.length }})
                    </div>
                    <div class="font-normal text-gray-500">
                        ({{ formatFriendStatus(status) }})
                    </div>
                    <div>
                        <Icon :name="friendStatusIcon(status).icon" size="1.5em"
                            :class="friendStatusIcon(status).color" />
                    </div>
                </div>
                <div v-if="getMessage(match.user.username)" class="w-full flex flex-row text-gray-500 text-md font-normal space-x-2">
                    <div v-if="getMessage(match.user.username)!.unread > 0" class="badge badge-success self-center">new</div>
                    <div class="flex-grow">
                        {{ getMessage(match.user.username)!.latest.content }}
                    </div>
                    <div>
                        {{ formatDate(getMessage(match.user.username)!.latest.time) }}
                    </div>
                </div>
            </NuxtLink>
        </NetworkDataContainer>
    </div>
</template>
