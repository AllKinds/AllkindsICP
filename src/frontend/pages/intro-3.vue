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
        <AllkindsTitle>
        </AllkindsTitle>

        <div>
            Connect with those who resonate, and see what you align on and where you differ.
        </div>

        <div class="grow" />

        <Btn to="/questions">Next</Btn>

        <ICFooter />
    </div>
</template>
