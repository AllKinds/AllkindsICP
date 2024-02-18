<script lang="ts" setup>

defineProps(["modelValue"]);
defineEmits(["update:modelValue"]);

</script>

<template>
    <div class="w-full my-10 flex flex-col items-center">
        <div class="w-full text-center mb-3">Importance {{ modelValue }}x</div>
        <div class="slidecontainer">
            <input type="range" :value="modelValue" @input="$emit('update:modelValue', ($event.target as any).value); false"
                class="w-72 slider" step="1" min="1" max="5" />
        </div>
    </div>
</template>

