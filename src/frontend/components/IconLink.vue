<script lang="ts" setup>
const props = defineProps<{
    to: string,
    logo?: string,
    size?: string
}>();

const icon = getIcon(props.logo ?? props.to);

</script>

<template>
    <Btn :to="props.to" class="p-[7px] w-auto m-0">
        <Icon :name="icon.icon" :size="props.size ?? '1.4em'" />
    </Btn>
</template>
