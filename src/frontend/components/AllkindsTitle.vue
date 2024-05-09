<script lang="ts" setup>
const props = defineProps<{
    logo?: string,
    linkTo?: string,
    logoUrl?: string,
}>();

</script>
<template>
    <div class="font-bold flex flex-row items-center w-full py-1 px-0 ml-0 text-xl min-h-20">
        <NuxtLink :to="props.linkTo" v-if="props.logoUrl">
            <img :src="props.logoUrl" height="50" width="50"
                class="mb-2 rounded-md bg-gray-900 hover:border-2 hover:bg-white" />
        </NuxtLink>
        <IconLink :to="props.linkTo ?? ''" :logo="props.logo" v-else-if="props.linkTo" />
        <div v-else style="width: 1em; height: 1em;" />

        <div class="flex-grow px-1 text-center flex-row">
            <slot>
                <div class="grape-nuts-regular">
                    <Icon name="ph:hexagon" size="0.8em" class="mr-4" />
                    <a style="color: #C79BFF">A</a>
                    <a style="color: #5155C1">l</a>
                    <a style="color: #51C171">l</a>
                    <a style="color: #FFBB54">k</a>
                    <a style="color: #FF6854">i</a>
                    <a style="color: #FF5754">n</a>
                    <a style="color: #F99DAB">d</a>
                    <a style="color: #21A7A0">s</a>
                </div>
            </slot>
        </div>
        <slot name="action">
            <div style="width: 1em; height: 1em;" />
        </slot>
    </div>
</template>
