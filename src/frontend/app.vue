<template>
  <div class="w-full">
    <div class="max-w-4xl mx-auto h-screen flex flex-col">
      <nav class="flex justify-between">
        <LoginBtn />
        <FontSizeBtn />
      </nav>

      <div class="grow flex flex-col items-center pb-3">
        <NuxtPage />
      </div>
    </div>
  </div>
</template>
