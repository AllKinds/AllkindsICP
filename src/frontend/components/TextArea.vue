<script lang="ts" setup>
const props = defineProps<{
    modelValue: string,
    placeholder?: string,
    minHeight?: number,
}>();
defineEmits(["update:modelValue", "ctrl-enter"]);

function resize(e: any) {
    const t = e.target || e;
    t.style.height = "1px";
    const height = t.scrollHeight;
    const total = Math.max(height + 2, props.minHeight || 0);
    t.style.setProperty("height", total + "px");
}

const el = ref();

onMounted(() => {
    const t = el.value;
    t.addEventListener("input", resize);
    t.addEventListener("change", resize);
    t.addEventListener("cut", resize);
    t.addEventListener("paste", resize);
    t.addEventListener("drop", resize);
    t.addEventListener("drop", resize);
    setTimeout(() => resize(t));
    setTimeout(() => resize(t), 400);
});

onUpdated(() => resize(el.value));

</script>

<template>
    <textarea ref="el" class="textarea textarea-bordered w-full bg-transparent textarea-lg"
        @input="$emit('update:modelValue', ($event.target as any).value); false" :value="modelValue"
        @keyup.ctrl.enter="$emit('ctrl-enter', modelValue)" :placeholder="placeholder">{{ modelValue }}</textarea>
</template>
