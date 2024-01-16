<script lang="ts" setup>
const app = useAppState();
if (inBrowser()) {
    app.loadUsers();
    app.loadUser();
}
</script>
<template>
    <div>
        <AllkindsTitle>Users</AllkindsTitle>
        <h1>You</h1>
        <NetworkDataContainer :networkdata="app.getUser()">
            {{ app.getUser().data?.user.displayName }}
            ({{ app.getUser().data?.user.username }})
            <pre>{{ JSON.stringify(app.getUser().data?.permissions, undefined, 2) }}
            </pre>
        </NetworkDataContainer>

        <h1>All users</h1>
        <NetworkDataContainer :networkdata="app.getUsers()">
            <div>
                Number of registered users: {{ app.getUsers().data?.length }}
            </div>
            <table class="table text-lg">
                <tr v-for="user in app.getUsers().data" class="hover:bg-slate-900">
                    <td>{{ user.displayName }}</td>
                    <td>({{ user.username }}):</td>
                    <td>{{ user.stats.points }}
                        <Icon name="gg:shape-hexagon" />,
                    </td>
                    <td>{{ user.stats.asked }} Q,</td>
                    <td>{{ user.stats.answered }} A,</td>
                    <td>{{ user.stats.boosts }} +</td>
                </tr>
            </table>
        </NetworkDataContainer>
    </div>
</template>