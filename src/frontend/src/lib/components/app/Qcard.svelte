<script lang="ts">
	import type { Question } from 'src/declarations/backend/backend.did';
	import ChevronDown from '$lib/assets/icons/chevronDown.svg?component';
	import ChevronUp from '$lib/assets/icons/chevronUp.svg?component';
	import Qcontent from './Qcontent.svelte';

	export let question: Question;
	let expandWindow: boolean = false;
	let qColor = question.color;

</script>

<div class="{qColor} h-fit w-full rounded-lg padding p-[1px] border-main">
	<div class="bg-transparent rounded-lg p-2">
		<button class="flex h-full w-full" on:click={() => (expandWindow = !expandWindow)}>
			<span class="text-2xl text-left grow {qColor}">
				{#if !expandWindow}
					{question.question}
					<div class="mt-14" />
				{/if}
			</span>

			<div class="sub-btn h-fit {qColor}">
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
</div>
