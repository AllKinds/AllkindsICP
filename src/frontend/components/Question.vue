<script lang="ts" setup>
import { type Question } from '~/utils/backend';
const emit = defineEmits(["answered", "answering", "delete", "recover"]);

const props = defineProps<{
    question: Question,
    link?: boolean,
    color?: ColorName,
    showScore?: boolean,
    deleteable?: boolean,
    loading?: boolean,
}>();

const q = props.question;

</script>

<template>
    <NuxtLink :to="props.link ? '/answer-question/' + q.id : ''"
        :class="[getColor(props.color || q.color as ColorName).color, {'line-through': q.deleted, 'opacity-75': q.deleted}]"
        class="border p-4 w-full my-2 rounded-lg block text-2xl font-medium text-ellipsis">
        {{ q.question }}

        <Icon v-if="props.loading" :name="getIcon('loading').icon" class="float-right"></Icon>
        <NuxtLink to="#" v-if="!q.deleted && !props.loading">
            <Icon v-if="props.deleteable" name="tabler:trash" class="float-right cursor-pointer"
                @click.stop="$emit('delete', props.question);" />
        </NuxtLink>
        <NuxtLink to="#" v-if="q.deleted && !props.loading">
            <Icon v-if="props.deleteable" name="tabler:trash-off" class="float-right cursor-pointer"
                @click.stop="$emit('recover', props.question);" />
        </NuxtLink>

        <span v-if="props.showScore" class="float-right text-sm">{{ q.points }}
            <Icon name="gg:shape-hexagon" />
        </span>
        <slot />
    </NuxtLink>
</template>
