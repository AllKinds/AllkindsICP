<script lang="ts" setup>
import { User } from '~/utils/backend';


definePageMeta({
    title: "Allkinds",
    layout: 'default'
});

const app = useAppState();

if (inBrowser()) {
    app.getTeam();
    app.loadTeamMembers(0);
}

const invite = (): string | undefined => {
    const team = app.getTeam();
    if (!team) return undefined;
    const code = app.getTeam()?.invite;
    if (!code?.length) return "";
    return document.location.origin + "/welcome" +
        "?team=" + encodeURIComponent(app.getTeam()?.key || "") +
        "&invite=" + encodeURIComponent(code[0]);
}
const remove = (user: User) => {
    let confirmed = window.confirm(
        "Do you want to remove this user?\n" +
        "\n" +
        "This will delete all questions and answers of this user:\n" +
        "Name: " + user.displayName + "\n" +
        "ID: " + user.username + "\n" +
        "Questions asked: " + user.stats.asked + "\n" +
        "Questions answered: " + user.stats.answered + "\n" +
        "\n" +
        "Remove this user from the team?"
    );

    if (confirmed) {
        // TODO!: implement
        // app.removeMember(user.username)
        addNotification("error", "Couldn't remover member.")
    }
}

</script>

<template>
    <div class="w-full flex-grow">
        <AllkindsTitle logo="ph:x-circle" link-to="/team-info">
        </AllkindsTitle>

        <NetworkDataContainer :networkdata="app.getTeamMembers()" class="w-full flex flex-col items-center">
            <div class="mb-5">
                Number of team members: {{ app.getTeamMembers().data?.length }}
            </div>
            <div v-for="user in app.getTeamMembers().data" :to="'/discover/' + user.username"
                class="text-xl font-bold flex flex-row w-full p-3 hover:bg-gray-900">
                <div class="flex-grow">
                    <span class="text-lg">
                        {{ user.displayName }}
                    </span>
                    <span class="text-sm">
                        ({{ user.username }},
                        {{ user.stats.points }}
                        <Icon name="gg:shape-hexagon" />,
                        q: {{ user.stats.asked }},
                        a: {{ user.stats.answered }})
                    </span>
                </div>
                <NuxtLink class="cursor-pointer" @click="remove(user)">
                    <Icon name="prime:user-minus" size="2em" />
                </NuxtLink>
            </div>
        </NetworkDataContainer>
        <div h-5></div>
    </div>
</template>