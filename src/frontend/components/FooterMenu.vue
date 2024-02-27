<script lang="ts" setup>


</script>
<template>
    <div class="w-full h-20 grid grid-cols-4 gap-1 text-xs">
        <NuxtLink to="/questions" :class="{ 'menu-active': $route.path === '/questions' }"
            class="p-[7px] w-auto m-0 flex flex-col items-center hover:text-black hover:bg-white rounded-lg">
            <Icon :name="getIcon('/questions').icon" size="2rem" class="mt-2" />
            Questions
        </NuxtLink>
        <NuxtLink to="/discover" :class="{ 'menu-active': $route.path === '/discover' }"
            class="p-[7px] w-auto m-0 flex flex-col items-center hover:text-black hover:bg-white rounded-lg">
            <Icon :name="getIcon('/discover').icon" size="2rem" class="mt-2" />
            Discover
        </NuxtLink>
        <NuxtLink to="/contacts" :class="{ 'menu-active': $route.path === '/contacts' }"
            class="p-[7px] w-auto m-0 flex flex-col items-center hover:text-black hover:bg-white rounded-lg">
            <Icon :name="getIcon('/contacts').icon" size="2rem" class="mt-2" />
            My&nbsp;contacts
        </NuxtLink>
        <NuxtLink to="/my-profile" :class="{ 'menu-active': $route.path === '/my-profile' }"
            class="p-[7px] w-auto m-0 flex flex-col items-center hover:text-black hover:bg-white rounded-lg">
            <Icon :name="getIcon('/my-profile').icon" size="2rem" class="mt-2" />
            My&nbsp;profile
        </NuxtLink>
    </div>
</template>