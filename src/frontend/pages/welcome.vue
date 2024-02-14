<script lang="ts" setup>

definePageMeta({
    title: "Join a team",
    layout: 'default'
});

const app = useAppState();

if (inBrowser()) {
    app.loadUser(0, false);
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

        <div>
            Allkinds.Team allows you to discover what your colleagues are up to and find those who share your values,
            interests, etc.
            <br /><br />
            Ask yes/no questions about what you consider important to you and to your team.
            <br /><br />
            Answer questions from your colleagues.
            <br /><br />
            See how you resonate with people and the entire team.
        </div>

        <div class="grow" />

        <Btn to="/about" class="self-center">Next</Btn>

        <ICFooter />
    </div>
</template>
