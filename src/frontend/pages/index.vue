<!--
Landing page
-->

<template>
  <header class="text-4xl p-4 text-center">
    <div class="font-bold flex justify-center">
      <img src="/logo.svg" class="w-10 h-10" />

      Allkinds
    </div>

    <div class="max-w-60 my-10">Where people<br />make people<br />happy</div>
  </header>

  <NuxtPage />

  <div class="grow flex flex-col items-center">
    <Btn to="/just-cause" class="w-60"> Just Cause </Btn>
    <Btn to="/project-design" class="w-60"> Project design </Btn>
    <Btn to="/main-mechanics" class="w-60"> Main mechanics </Btn>
    <Btn to="/season-0" class="w-60"> Season#0 </Btn>
    <Btn to="/ask-for-invite" class="btn-disabled w-60"> Ask for invite </Btn>
  </div>

  <footer class="text-center w-full m-2">
    <span class="text-xs">
      Powered by
      <a href="https://internetcomputer.org/">
        InternetComputer <img src="/icp.png" class="h-5 inline" />
      </a>
    </span>
  </footer>
</template>
