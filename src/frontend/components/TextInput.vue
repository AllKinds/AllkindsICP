<script lang="ts" setup>
defineProps(["modelValue", "placeholder"]);
defineEmits(["update:modelValue"]);

const el = ref();

</script>

<template>
    <input ref="el" class="textarea textarea-bordered textarea-lg" :value="modelValue"
        @input="$emit('update:modelValue', ($event.target as any).value);" :placeholder="placeholder" />
</template>
