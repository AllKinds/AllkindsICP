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
        <AllkindsTitle class="py-16" />

        <div class="p-8 text-center">
            <div class="lexend-regular">
                Connect with those who resonates, and see where you align and differ.
            </div>
        </div>

        <div class="grow" />

        <Btn to="/logged-in">Ok, start</Btn>

        <ICFooter />
    </div>
</template>
