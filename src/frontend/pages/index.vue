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
        console.log("logged in");
        if (hasInvite()) {
            navigateTo("/welcome")
        } else {
            navigateTo("/team-info");
        }
    } else {
        addNotification('error', "Log in failed:\n" + res.err); // TODO format error
    }
}

</script>

<template>
    <div class="w-full flex-grow flex flex-col items-center">
        <AllkindsTitle>Allkinds.Teams</AllkindsTitle>

        <div class="text-2xl p-4 text-center">
            <div class="max-w-60 my-24 font-bold">
                Make your team stronger <br> and your employees <br> happier.
            </div>
        </div>


        <div class="grow flex flex-col items-center">
        </div>

        <Btn to="/about" class="w-80"> Learn more </Btn>

        <Btn v-if="auth.loggedIn && hasInvite()" class="w-80 mt-2" to="/welcome">
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

        <ICFooter />
    </div>
</template>
