<script lang="ts" setup>
import moment from 'moment';

definePageMeta({
    title: "Allkinds",
    footerMenu: false,
});

const app = getAppState();

const route = useRoute();

const user = route.params.user + "";
const userChat = app.chat.get(user)
const team = app.getTeamKey();

const message = ref("");
const pending = ref("");

if (inBrowser()) {
    userChat.load(team, 0);
    app.friends.load(0);

    setInterval(() => userChat.update(team, 10).catch(()=>null), 10000);
};

const sendMessage = async () => {
    const content = message.value;
    message.value = "";
    console.log("sending message", content, "to", user);
    if (content.trim().length > 0) {
        pending.value = content;
        await app.sendMessage(user, content);
        await userChat.load(team, 0);
        pending.value = "";
    } else {
        console.log("message must not be empty");
    }
};

const pageLoad = moment();

const formatDate = (date: bigint) => {
    const now = moment();
    const time = moment(Number(date / 1000000n));
    if (now.isBefore(time)) {
        return "now";
    }
    return time.fromNow();
}

</script>

<template>
    <div class="w-full flex-grow flex flex-col">
        <AllkindsTitle class="w-full" logo="back" :linkTo="'/contacts/' + user">
            <NuxtLink :to="'/contacts/' + user" class="m-auto">
                {{ user }}
            </NuxtLink>
        </AllkindsTitle>

        {{ userChat.get().status }}

        <div class="chat-messages flex-grow flex flex-col-reverse font-light h-20 pb-2 overflow-y-auto scrollbar">
            <NetworkDataContainer :networkdata="userChat.get()">
            </NetworkDataContainer>
            <div v-if="pending.trim().length > 0" class="chat-message chat-self">
                {{ pending }}
                <div class="text-sm font-light w-full text-right">
                    <Icon name="line-md:loading-alt-loop" />
                </div>
            </div>
            <div v-for="msg in userChat.get().data?.slice().reverse()" class="chat-message"
                :class="msg.sender ? 'chat-self' : 'chat-other'">
                {{ msg.content }}
                <div class="text-sm font-light w-full text-right text-gray-400">
                    {{ formatDate(msg.time) }}
                </div>
            </div>
        </div>

        <div class="w-full flex flex-row bg-slate-900 p-2 mb-[-12px]">
            <TextInput placeholder="Message" v-model.trim="message" @keyup.enter="sendMessage"
                class="flex-grow rounded-full py-1 m-1" />
            <Icon name="lucide:send" size="2em" class="m-4" @click="sendMessage" />
        </div>
    </div>
</template>
