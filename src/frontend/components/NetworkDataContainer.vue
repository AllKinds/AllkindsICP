
<script lang="ts" setup>
import { NetworkData } from '~/composables/appState';


const props = defineProps<{
    networkdata: NetworkData<unknown>,
}>();

</script>

<template>
    <div class="">
        <div v-if="props.networkdata.status === 'ok'" class="">
            <slot />
        </div>
        <div v-else-if="props.networkdata.status === 'requested'" class="text-center">
            <Icon name="line-md:loading-alt-loop" size="5em" class="absolute mt-8" />
            <div class="opacity-20">
                <slot />
            </div>
        </div>
        <div v-else class="bg-error">
            {{ props.networkdata.status }}
            <slot />
        </div>
    </div>
</template>