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

        <div class="text-4xl p-8 text-center">
            <div class="lexend-big">
                Discover allkinds<br>of like-minded <br>people.
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
