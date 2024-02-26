<script lang="ts" setup>
definePageMeta({
    title: "About",
    layout: 'default'
});

const app = useAppState();

if (inBrowser()) {
    app.loadUser(0, false);
}

</script>

<template>
    <div class="w-full flex-grow flex flex-col items-center">
        <AllkindsTitle class="py-16" />

        <div class="p-8 text-center">
            <div class="lexend-regular">
                Ask each other yes/no questions.<br><br>
                It’s completely anonymous.
            </div>
        </div>

        <div class="grow" />

        <Btn to="/intro-2">Sure</Btn>

        <ICFooter />
    </div>
</template>
