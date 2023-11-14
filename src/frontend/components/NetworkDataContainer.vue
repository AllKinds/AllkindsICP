
<script lang="ts" setup>
import { NetworkData } from '~/composables/appState';


const props = defineProps<{
    networkdata: NetworkData<unknown>,
}>();

</script>

<template>
    <div class="">
        <div v-if="props.networkdata.status === 'ok'" class="bg-success">
            {{ props.networkdata.status }}
            <slot />
        </div>
        <div v-else-if="props.networkdata.status === 'requested'" class="bg-warning">
            <slot />
        </div>
        <div v-else class="bg-error">
            {{ props.networkdata.status }}
            <slot />
        </div>
    </div>
</template>