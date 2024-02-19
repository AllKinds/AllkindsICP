<script lang="ts" setup>


</script>
<template>
    <div class="w-full h-20 flex flex-row justify-between text-sm">
        <NuxtLink to="/questions" class="p-[7px] w-auto m-0 flex flex-col items-center hover:invert bg-black rounded-lg">
            <Icon :name="getIcon('/questions').icon" size="2rem" class="mt-2" />
            Questions
        </NuxtLink>
        <NuxtLink to="/discover" class="p-[7px] w-auto m-0 flex flex-col items-center hover:invert bg-black rounded-lg">
            <Icon :name="getIcon('/discover').icon" size="2rem" class="mt-2" />
            Discover
        </NuxtLink>
        <NuxtLink to="/contacts" class="p-[7px] w-auto m-0 flex flex-col items-center hover:invert bg-black rounded-lg">
            <Icon :name="getIcon('/contacts').icon" size="2rem" class="mt-2" />
            My contacts
        </NuxtLink>
        <NuxtLink to="/my-profile" class="p-[7px] w-auto m-0 flex flex-col items-center hover:invert bg-black rounded-lg">
            <Icon :name="getIcon('/my-profile').icon" size="2rem" class="mt-2" />
            My profile
        </NuxtLink>
    </div>
</template>