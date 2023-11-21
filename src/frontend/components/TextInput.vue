<script lang="ts" setup>
defineProps(["modelValue", "placeholder"]);
defineEmits(["update:modelValue"]);

const el = ref();

const largeFont = useLargeFont();
</script>

<template>
    <input ref="el" class="textarea textarea-bordered textarea-md" :class="largeFont ? 'textarea-lg' : 'textarea-md'"
        :value="modelValue" @input="$emit('update:modelValue', ($event.target as any).value);" :placeholder="placeholder" />
</template>
