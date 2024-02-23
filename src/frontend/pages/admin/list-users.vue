<script lang="ts" setup>
const app = getAppState();

if (inBrowser()) {
    app.users.load();
    app.user.load();
}
</script>
<template>
    <div>
        <AllkindsTitle>Users</AllkindsTitle>
        <h1>You</h1>
        <NetworkDataContainer :networkdata="app.user.get()">
            {{ app.user.get().data?.user.displayName }}
            ({{ app.user.get().data?.user.username }})
            <pre>{{ JSON.stringify(app.user.get().data?.permissions, undefined, 2) }}
            </pre>
        </NetworkDataContainer>

        <h1>All users</h1>
        <NetworkDataContainer :networkdata="app.users.get()">
            <div>
                Number of registered users: {{ app.users.get().data?.length }}
            </div>
            <table class="table text-lg">
                <tr v-for="user in app.users.get().data" class="hover:bg-slate-900">
                    <td>{{ user.displayName }}</td>
                    <td>{{ user.username }}</td>
                    <td>{{ user.stats.points }}&nbsp;
                        <Icon name="gg:shape-hexagon" />
                    </td>
                    <td>{{ user.stats.asked }}&nbsp;Q</td>
                    <td>{{ user.stats.answered }}&nbsp;A</td>
                    <td>{{ user.stats.boosts }}&nbsp;+</td>
                </tr>
            </table>
        </NetworkDataContainer>
    </div>
</template>