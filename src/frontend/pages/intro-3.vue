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
        <AllkindsTitle><div class="grape-nuts-regular">
            <a style="color: #C79BFF">A</a>
            <a style="color: #5155C1">l</a>
            <a style="color: #51C171">l</a>
            <a style="color: #FFBB54">k</a>
            <a style="color: #FF6854">i</a>
            <a style="color: #FF5754">n</a>
            <a style="color: #F99DAB">d</a>
            <a style="color: #21A7A0">s</a>
            </div></AllkindsTitle>

        <div class="p-4 text-center">
            <div class="lexend-regular">
                Connect with those who resonates, and see where you align and differ.
            </div>
        </div>

        <div class="grow" />

        <Btn to="/questions">Ok, start</Btn>

        <ICFooter />
    </div>
</template>
