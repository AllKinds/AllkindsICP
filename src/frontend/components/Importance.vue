<script lang="ts" setup>

defineProps(["modelValue"]);
defineEmits(["update:modelValue"]);

</script>

<template>
    <div class="w-full mt-3 flex flex-row place-content-evenly">
        <NuxtLink class="p-7 link" :class="{ 'text-gray-500 pointer-events-none': modelValue <= 1 }"
            @click="$emit('update:modelValue', Math.max(1, modelValue - 1))">
            <Icon name="ph:minus-circle" size="2em" />
        </NuxtLink>
        <div class="text-center relative">
            <Icon name="mdi:hexagon-outline" size="5em" />
            <div class="absolute top-7 w-full text-center">+{{ modelValue }}</div>

            <div class="w-full text-center mb-3">Importance</div>
        </div>
        <NuxtLink class="p-7 link" :class="{ 'text-gray-500 pointer-events-none': modelValue >= 20 }"
            @click="$emit('update:modelValue', Math.min(20, modelValue + 1))">
            <Icon name="ph:plus-circle" size="2em" />
        </NuxtLink>
    </div>
</template>

