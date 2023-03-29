<script lang="ts">
	import type { Question } from 'src/declarations/backend/backend.did';

	import ChevronDown from '$lib/assets/icons/chevronDown.svg?component';
	import ChevronUp from '$lib/assets/icons/chevronUp.svg?component';
	import Qcontent from './Qcontent.svelte';

	export let question: Question;
	let expandWindow: boolean = false;
</script>

<div
	class="odd:bg-slate-300/40 even:bg-slate-300/20 dark:odd:bg-slate-700/10 dark:even:bg-slate-700/30 h-fit w-full border-main rounded-lg padding"
>
	<button class="flex h-full w-full hover-color " on:click={() => (expandWindow = !expandWindow)}>
		<span class="text-2xl text-left font-color-sub grow">
			{#if !expandWindow}
				{question.question}
				<div class="mt-14" />
			{/if}
		</span>

		<div class="hover-circle">
			{#if !expandWindow}
				<ChevronDown />
			{:else}
				<ChevronUp />
			{/if}
		</div>
	</button>

	{#if expandWindow}
		<Qcontent {question} />
	{/if}
</div>
