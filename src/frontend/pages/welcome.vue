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
    <div class="w-full flex-grow flex flex-col">
        <AllkindsTitle link-to="/select-team"></AllkindsTitle>

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
