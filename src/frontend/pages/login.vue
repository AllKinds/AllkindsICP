<!--
Page to select login provider and initiate login process
-->

<script lang="ts" setup>
definePageMeta({ middleware: ["auth"], title: "Log in" });

const largeFont = useState("largeFont", () => false);

async function login(provider: Provider) {
  if (await checkAuth(provider)) {
    navigateTo("/welcome");
  }
}
</script>

<template>
  <div class="grow flex flex-col items-center">
    <TextBlock class="max-w-sm text-center" align="text-center">
      <p>
        Allkinds is powered by the Internet Computer. It’s fully decentralised and
        secured. <br />
        <img src="/icp.png" class="w-20 inline" />
      </p>
    </TextBlock>

    <Btn class="w-72" :class="{ 'h-16': largeFont }" @click="login('II')">
      Log in with Internet&nbsp;Identity
    </Btn>
    <Btn class="w-72" @click="login('NFID')"> Log in with email </Btn>
    <Link to="/" class="m-3 link outline-none"> cancel </Link>
  </div>
</template>
