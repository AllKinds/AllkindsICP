<!--
Landing page
-->
<script lang="ts" setup>


definePageMeta({
    title: "Login",
    layout: 'default'
});

const teamSelected = () => window.localStorage.getItem("team") && !window.localStorage.getItem("invite");
const hasInvite = () => window.localStorage.getItem("invite");

const auth = useAuthState();
await checkAuth(false);

async function login(provider: Provider) {
    if (!inBrowser()) return;

    const res = await loginTest(provider);
    if (res.ok) {
        auth.setClient(!!res.val);
        navTo("/logged-in");
    } else {
        addNotification('error', "Log in failed:\n" + res.err); // TODO: format error
    }
}

</script>

<template>
    <div class="w-full flex-grow flex flex-col items-center">
        <AllkindsTitle class="py-16" />

        <div class="text-4xl p-8 text-center">
            <div class="lexend-big leading-normal">
                    Your<br>
                    Digital<br>
                    Pesonality<br>
                    Identity
            </div>
        </div>

        <div class="grow"/>

        <div class="grow flex flex-col items-center">
            Web3 Private Social Network
        </div>

        <Btn v-if="auth.loggedIn && hasInvite()" class="w-80 mt-2" to="/logged-in">
            Join
        </Btn>
        <Btn v-else-if="auth.loggedIn && teamSelected()" class="w-80 mt-2" to="/team-info">
            Welcome back
        </Btn>
        <Btn v-else-if="auth.loggedIn" class="w-80 mt-2" to="/select-team">
            Select a team
        </Btn>
        <Btn v-else class="w-80 mt-2" @click="login('II')">
            Join with Internet&nbsp;Identity
        </Btn>

        <Btn to="/about" class="w-80">About the project</Btn>

        <ICFooter />
    </div>
</template>
