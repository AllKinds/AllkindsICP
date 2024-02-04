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
    <AllkindsTitle>
    </AllkindsTitle>

    <div>
      Allkinds.Team is built fully on blockchain (The&nbsp;Internet&nbsp;Computer).
      <br /><br />
      It’s main feature is to guarantee your privacy while asking and answering each other questions.
      <br /><br />
      While we are just piloting with you - we would like to ask you to track your actions so we understand how to
      improve the service.
    </div>

    <div class="grow" />

    <Btn v-if="hasInvite && app.user.status === 'ok'" to="/verify-invite">Next</Btn>
    <Btn v-else-if="hasInvite" to="/register">Next</Btn>
    <Btn v-else to="/select-team">Next</Btn>

    <ICFooter />
  </div>
</template>
