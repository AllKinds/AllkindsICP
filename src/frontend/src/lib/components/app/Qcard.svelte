<script lang="ts">
	import type { Question } from 'src/declarations/backend/backend.did';
	import ChevronDown from '$lib/assets/icons/chevronDown.svg?component';
	import ChevronUp from '$lib/assets/icons/chevronUp.svg?component';
	import Qcontent from './Qcontent.svelte';
	import { onMount } from 'svelte';

	export let question: Question;
	let expandWindow: boolean = false;

	$: hue = Number(question.color);
	$: cssVariables = {
		'primary-color': `hsl(${hue} 100% 70%)`,
		'secondary-color': `hsl(${hue} 100% 60%)`
	};

	$: styleValues = Object.entries(cssVariables)
		.map(([key, value]) => `--${key}:${value}`)
		.join(';');
</script>

<div style={styleValues} class="bg-fancy h-fit w-full rounded-lg padding p-[1px]">
	<div class="bg-transparent rounded-lg p-2">
		<button class="flex h-full w-full hover-color " on:click={() => (expandWindow = !expandWindow)}>
			<span class="text-2xl text-left grow text-zinc-900">
				{#if !expandWindow}
					{question.question}
					<div class="mt-14" />
				{/if}
			</span>

			<div class="sub-btn h-fit text-zinc-900">
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
