<script lang="ts" setup>

import { colors } from '~/utils/color';

defineProps(["modelValue"]);
defineEmits(["update:modelValue"]);

</script>

<template>
    <div class="flex flex-row w-full pl-1">
        <NuxtLink v-for="(color, name) in colors" class="w-3 grow h-12 mr-1 rounded-3xl text-center pt-3 font-bold"
            @click="$emit('update:modelValue', name)" :class="[color.color, { 'border': modelValue === name }]">
            <Icon v-if="modelValue === name" name="zondicons:checkmark" />
        </NuxtLink>
    </div>
</template>
