<script lang="ts" setup>
definePageMeta({
    title: "About",
    layout: 'default'
});

const app = useAppState();
let hasInvite = false;

if (inBrowser()) {
    app.loadUser(0, false);
    hasInvite = !!window.localStorage.getItem("invite")
}

</script>

<template>
    <div class="w-full flex-grow flex flex-col items-center">
        <AllkindsTitle>Allkinds</AllkindsTitle>

        <div>
            Ask each other yes/no questions.
        </div>

        <div class="grow" />

        <Btn to="/intro-2">I understand</Btn>

        <ICFooter />
    </div>
</template>
