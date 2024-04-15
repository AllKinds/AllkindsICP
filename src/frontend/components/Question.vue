<script lang="ts" setup>
import { type Question } from '~/utils/backend';
const emit = defineEmits(["answered", "answering", "delete"]);

const props = defineProps<{
    question: Question,
    link?: boolean,
    color?: ColorName,
    showScore?: boolean,
    deleteable?: boolean,
}>();

const q = props.question;

</script>

<template>
    <NuxtLink :to="props.link ? '/answer-question/' + q.id : ''"
        :class="getColor(props.color || q.color as ColorName).color"
        class="border p-4 w-full my-2 rounded-lg block text-2xl font-medium text-ellipsis">
        {{ q.question }}

        <Icon v-if="props.deleteable" name="tabler:trash" class="float-right cursor-pointer"
            @click.stop="$emit('delete', props.question);" />

        <span v-if="props.showScore" class="float-right text-sm">{{ q.points }}
            <Icon name="gg:shape-hexagon" />
        </span>
        <slot />
    </NuxtLink>
</template>
