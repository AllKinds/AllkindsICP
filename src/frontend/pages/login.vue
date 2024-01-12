<!--
Page to select login provider and initiate login process
-->

<script lang="ts" setup>

definePageMeta({
    title: "Allkinds",
    layout: 'default'
});

const auth = useAuthState();

async function login(provider: Provider) {
    if ((await auth.login(provider)).tag === 'ok') {
        console.log("logged in");
        navigateTo("/select-team");
    }
}

const isAuth = await auth.check();
if (isAuth.tag === 'ok' && isAuth.val) {
    console.warn("navigated to /login, but already logged in");
    navigateTo("/select-team");
}

</script>

<template>
    <div class="grow flex flex-col items-center">
        <TextBlock class="max-w-sm text-center" align="text-center">
            <p>
                Allkinds is powered by the Internet&nbsp;Computer.<br />
                It’s fully decentralised and secured. <br />
                <img src="/icp.png" class="w-20 inline" />
            </p>
        </TextBlock>

        <div class="w-full flex-grow"></div>
        <div class="w-full flex-grow"></div>

        <Btn class="w-72" @click="login('II')">
            Log in with Internet&nbsp;Identity
        </Btn>
        <Lnk to="/"> Cancel </Lnk>
        <div class="w-full flex-grow"></div>
    </div>
</template>
