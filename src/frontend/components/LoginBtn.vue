<script lang="ts" setup>

const auth = useAuthState();

const logout = () => {
    auth.logout();
    navigateTo("/");
};
</script>

<template>
    <NuxtLink to="/login" class="btn text-xl" v-if="auth.loggedIn">
        Login
        <Icon name="material-symbols:login" />
    </NuxtLink>
    <button class="btn text-xl" v-else @click="logout">
        Logout
        <Icon name="material-symbols:logout" />
    </button>
</template>
