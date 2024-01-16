<script lang="ts" setup>
import { useAuthState } from '#imports';
import { Effect } from 'effect';

definePageMeta({
    title: "Allkinds",
    layout: 'default'
});

const app = useAppState();
const auth = useAuthState();

const logout = () => {
    auth.logout();
    app.$reset();
    navigateTo("/");
};

if (inBrowser()) {
    app.loadUser();
    app.loadAnsweredQuestions();
    app.loadOwnQuestions();
}
</script>


<template>
    <div class="w-full flex-grow">
        <AllkindsTitle logo="ph:x-circle" logoSize="2em" linkTo="/questions">

        </AllkindsTitle>

        <div class="flex flex-col">
            <!-- TODO: link to something -->
            <Btn to="https://github.com/AllKinds/AllkindsICP/wiki/Allkinds" class="w-96">More about Allkinds.Teams</Btn>
            <Btn to="https://allkinds.xyz" class="w-96 mt-10">We want to hear from you</Btn>
            <Btn @click="logout()" class="w-96">Sign out</Btn>


            <Btn class="w-96 mt-20 bg-red-600">Delete all my answers</Btn>
            <Btn class="w-96 bg-red-600">Delete my account and all data</Btn>
        </div>
    </div>
</template>