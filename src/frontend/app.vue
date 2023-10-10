<template>
  <div class="w-full">
    <div class="max-w-4xl mx-auto h-screen flex flex-col">
      <nav class="flex justify-between">
        <LoginBtn />
        <FontSizeBtn />
      </nav>

      <header class="text-4xl p-4 text-center">
        <div class="font-bold flex justify-center">
          <img src="/logo.svg" class="w-10 h-10" />

          Allkinds
        </div>

        <div class="max-w-60 my-10">Where people<br />make people<br />happy</div>
      </header>

      <div class="grow flex flex-col items-center">
        <a href="#" class="btn btn-outline w-60 m-3 rounded-full">Just Cause</a>
        <a href="#" class="btn btn-outline w-60 m-3 rounded-full">Project design</a>
        <a href="#" class="btn btn-outline w-60 m-3 rounded-full">Main mechanics</a>
        <a href="#" class="btn btn-outline w-60 m-3 rounded-full">Season#0</a>
        <a href="#" class="btn btn-outline btn-disabled w-60 m-3 rounded-full"
          >Ask for invite</a
        >
        <slot />
      </div>

      <footer class="text-center w-full">
        <span class="text-xs">
          Powered by InternetComputer <img src="/icp.png" class="h-5 inline" />
        </span>
      </footer>
    </div>
  </div>
</template>
