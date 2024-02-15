<!--
Page to check user registration state
-->

<script lang="ts" setup>

definePageMeta({
    title: "Allkinds",
    layout: 'default'
});

const app = useAppState();

const hasInvite = () => window.localStorage.getItem("invite");
const teamSelected = () => window.localStorage.getItem("team") && !window.localStorage.getItem("invite");

if (inBrowser()) {
    // loadUser will redirect to /register or /login if user doesn't exist
    app.loadUser(0).then(
        (u) => {
            if (hasInvite())
                navigateTo("/verify-invite")
            else if (teamSelected())
                navigateTo("/questions")
            else
                navigateTo("/select-team")
        }
    );
}

</script>

<template>
    <div class="grow flex flex-col items-center">
        <div class="w-full flex-grow h-10"></div>
        <Icon name="line-md:loading-alt-loop" size="5em" class="absolute mt-8" />
        <div class="w-full flex-grow"></div>
    </div>
</template>
