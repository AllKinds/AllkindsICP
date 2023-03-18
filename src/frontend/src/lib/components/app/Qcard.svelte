<script lang="ts">
	import type { AnswerKind, LikeKind, Question } from 'src/declarations/backend/backend.did';

	import EllipsisVertical from '$lib/assets/icons/ellipsis-vertical.svg?component';
	import ChevronUp from '$lib/assets/icons/chevronUp.svg?component';
	import Qcontent from './Qcontent.svelte';

	export let question: Question;
	let expandWindow: boolean = false;
</script>

<div
	class="odd:bg-slate-300/40 even:bg-slate-300/20 dark:odd:bg-slate-700/10 dark:even:bg-slate-700/30 h-fit w-full border-main rounded-lg p-2 md:p-3 lg:p-5"
>
	<button
		class="flex h-full w-full hover-color "
		on:click={() => (expandWindow = !expandWindow)}
	>
		<span class="break-all text-2xl text-left grow">
			{#if !expandWindow}
				{question.question}
				<div class="mt-14" />
			{/if}
		</span>

		<div class="">
			{#if !expandWindow}
				<EllipsisVertical />
			{:else}
				<ChevronUp />
			{/if}
		</div>
	</button>

	{#if expandWindow}
		<Qcontent {question} />
	{/if}
</div>
