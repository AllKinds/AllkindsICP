<script lang="ts" setup>
import type { User } from '~/utils/backend';


definePageMeta({
    title: "Allkinds",
    layout: 'default'
});

const app = useAppState();
const loading = useState('loading', () => true);
loading.value = false;

if (inBrowser()) {
    app.getTeam();
    app.loadTeamMembers(0);
    app.loadTeamAdmins(0);
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
        loading.value = true;
        app.leaveTeam(user.username).then(
            () => { app.loadTeamMembers(0) }
        ).then(
            () => { addNotification("ok", "User is removed from team") },
            () => { addNotification("error", "Couldn't remove member") },
        ).finally(
            () => { loading.value = false }
        );
    }
}

const makeAdmin = (user: User, admin: boolean) => {
    let confirmed = window.confirm(
        admin ?
            "Give " + user.displayName + " (" + user.username + ")" + " admin permissions in this team?" :
            "Remove admin permissions from " + user.displayName + " (" + user.username + ")?"
    );

    if (confirmed) {
        loading.value = true;
        app.setTeamAdmin(user.username, admin).then(
            () => { app.loadTeamAdmins(0) }
        ).then(
            () => { addNotification("ok", "User set as admin") },
            () => { addNotification("error", "Couldn't set user as admin") },
        ).finally(
            () => { loading.value = false }
        )
    }
}

</script>

<template>
    <div class="w-full flex-grow">
        <AllkindsTitle logo="x" link-to="/team-info">
            <span />
        </AllkindsTitle>

        <NetworkDataContainer :networkdata="app.getTeamAdmins()" class="w-full flex flex-col items-center">
            <div class="mb-5">
                Number of team admins: {{ app.getTeamAdmins().data?.length }}
            </div>
            <div v-for="user in app.getTeamAdmins().data" :to="'/discover/' + user.username"
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
                <NuxtLink class="cursor-pointer ml-2" @click="makeAdmin(user, false)">
                    <Icon v-if="loading" name="line-md:loading-alt-loop" size="2em" />
                    <Icon v-else name="mdi:shield-remove-outline" size="1.5em" />
                </NuxtLink>
            </div>
        </NetworkDataContainer>

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
                    <Icon v-if="loading" name="line-md:loading-alt-loop" size="2em" />
                    <Icon v-else name="prime:user-minus" size="2em" />
                </NuxtLink>
                <NuxtLink class="cursor-pointer ml-2" @click="makeAdmin(user, true)">
                    <Icon v-if="loading" name="line-md:loading-alt-loop" size="2em" />
                    <Icon v-else name="mdi:shield-plus-outline" size="1.5em" />
                </NuxtLink>
            </div>
        </NetworkDataContainer>
        <div h-5></div>
    </div>
</template>
