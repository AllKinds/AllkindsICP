<script lang="ts" setup>

const props = defineProps<{
    networkdata: NetworkData<unknown>,
}>();

const status = () => props.networkdata.status;

</script>

<template>
    <div v-if="status() === 'ok'">
        <slot />
    </div>
    <div v-else-if="status() === 'requested'" class="text-center">
        <Icon name="line-md:loading-alt-loop" size="5em" class="absolute mt-8" />
        <div class="opacity-20">
            <slot />
        </div>
    </div>
    <div v-else-if="status() === 'init'" class="text-center">
        loading...
    </div>
    <div v-else class="w-full border border-red-700 p-4 rounded-lg">
        <div class="text-lg pb-8">
            {{ formatError(props.networkdata.err!) }}
        </div>

        <slot />
    </div>
</template>
