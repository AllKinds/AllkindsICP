<script lang="ts" setup>
defineProps(["modelValue", "placeholder"]);
defineEmits(["update:modelValue", "ctrl-enter"]);

function resize(e: any) {
    const t = e.target || e;
    t.style.height = "1px";
    const height = t.scrollHeight;
    const total = height + 2;
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
});

onUpdated(() => resize(el.value));

const largeFont = useLargeFont();
watch(largeFont, () => resize(el.value));
</script>

<template>
    <textarea ref="el" class="textarea textarea-bordered textarea-md w-full"
        :class="largeFont ? 'textarea-lg' : 'textarea-md'"
        @input="$emit('update:modelValue', ($event.target as any).value); false" :value="modelValue"
        @keyup.crtl.enter="$emit('ctrl-enter', modelValue)" :placeholder="placeholder">{{ modelValue }}</textarea>
</template>
