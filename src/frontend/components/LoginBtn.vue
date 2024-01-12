<script lang="ts" setup>

const largeFont = useLargeFont();
const auth = useAuthState();

const logout = () => {
    auth.logout();
    navigateTo("/");
};
</script>

<template>
    <NuxtLink to="/login" class="btn" :class="{ 'text-xl': largeFont }" v-if="auth.loggedIn">
        Login
        <Icon name="material-symbols:login" />
    </NuxtLink>
    <button class="btn" :class="{ 'text-xl': largeFont }" v-else @click="logout">
        Logout
        <Icon name="material-symbols:logout" />
    </button>
</template>
