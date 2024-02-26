<script lang="ts" setup>
import { type Question } from '~/utils/backend';
const emit = defineEmits(["answered", "answering"]);

const props = defineProps<{
    question: Question,
    link?: boolean,
    color?: ColorName,
    showScore?: boolean,
}>();

const q = props.question;

</script>

<template>
    <NuxtLink :to="props.link ? '/answer-question/' + q.id : ''"
        :class="getColor(props.color || q.color as ColorName).color"
        class="border p-4 w-full my-2 rounded-lg block text-2xl font-medium text-ellipsis">
        <!--Icon v-if="props.link" name="material-symbols:arrow-forward-ios" class="float-right mt-1" /-->
        {{ q.question }}
        <span v-if="props.showScore" class="float-right text-sm">{{ q.points }}
            <Icon name="gg:shape-hexagon" />
        </span>
        <slot />
    </NuxtLink>
</template>
