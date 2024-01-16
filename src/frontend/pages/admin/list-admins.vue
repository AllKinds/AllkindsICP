<script lang="ts" setup>
const app = useAppState();
if (inBrowser()) {
    app.loadAdmins();
    app.loadUser();
}
</script>
<template>
    <div>
        <AllkindsTitle>Admins</AllkindsTitle>
        <h1>Your Permissions</h1>
        <NetworkDataContainer :networkdata="app.getUser()">
            {{ app.getUser().data?.user.displayName }}
            ({{ app.getUser().data?.user.username }})
            <pre>{{ JSON.stringify(app.getUser().data?.permissions, undefined, 2) }}
            </pre>
        </NetworkDataContainer>

        <h1>All admins</h1>
        <NetworkDataContainer :networkdata="app.getAdmins()">
            <div>
                Number of users with custom permissions: {{ app.getAdmins().data?.length }}
            </div>
            <div v-for="admin in app.getAdmins().data">
                {{ admin.user.displayName }}
                ({{ admin.user.username }})
                <pre>{{ JSON.stringify(admin.permissions, undefined, 2) }}
            </pre>
            </div>
        </NetworkDataContainer>
    </div>
</template>