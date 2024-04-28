<script lang="ts" setup>

const app = useAppState();
const user = () => app.getUser().data;

const notification = (category: "newQuestions" | "friendRequests" | "rewards" | "chat", team?: string): bigint => {
    const u = user();
    if (!u) return 0n;
    console.log("user", u)
    let count = 0n;
    for (let n of u.notifications) {
        if (!team || n.team.indexOf(team) >= 0) {
            const ev: any = n.event;
            if (category in ev) {
                if (category === "chat") {
                    count += ev[category].unread || 0n;
                } else {
                    count += ev[category] || 1n;
                }
            }
        }
    }
    console.log("count", count, category)
    return count
}

if (inBrowser()) {
}

</script>
<template>
    <div class="w-full h-20 grid grid-cols-4 gap-1 text-xs">
        <NuxtLink to="/questions" :class="{ 'menu-active': $route.path === '/questions' }"
            class="p-[7px] w-auto m-0 flex flex-col items-center hover:text-black hover:bg-white rounded-lg relative">
            <span v-if="notification('newQuestions', app.team)" class="absolute right-2 text-sm text-red-600 px-5">{{
            notification('newQuestions', app.team) }}</span>
            <Icon :name="getIcon('/questions').icon" size="2rem" class="mt-2" />
            Questions
        </NuxtLink>
        <NuxtLink to="/discover" :class="{ 'menu-active': $route.path === '/discover' }"
            class="p-[7px] w-auto m-0 flex flex-col items-center hover:text-black hover:bg-white rounded-lg">
            <Icon :name="getIcon('/discover').icon" size="2rem" class="mt-2" />
            Discover
        </NuxtLink>
        <NuxtLink to="/contacts" :class="{ 'menu-active': $route.path === '/contacts' }"
            class="p-[7px] w-auto m-0 flex flex-col items-center hover:text-black hover:bg-white rounded-lg relative">
            <span v-if="notification('friendRequests', app.team) + notification('chat', app.team)"
                class="absolute right-2 text-sm text-red-600 px-5">
                {{ notification('friendRequests', app.team) + notification('chat', app.team) }}
            </span>
            <Icon :name="getIcon('/contacts').icon" size="2rem" class="mt-2" />
            My&nbsp;contacts
        </NuxtLink>
        <NuxtLink to="/my-profile" :class="{ 'menu-active': $route.path === '/my-profile' }"
            class="p-[7px] w-auto m-0 flex flex-col items-center hover:text-black hover:bg-white rounded-lg">
            <Icon :name="getIcon('/my-profile').icon" size="2rem" class="mt-2" />
            My&nbsp;profile
        </NuxtLink>
    </div>
</template>
