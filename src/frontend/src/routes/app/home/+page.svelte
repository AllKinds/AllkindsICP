<script lang="ts">
	import Qcard from '$lib/components/app/Qcard.svelte';
	import Add from '$lib/assets/icons/plus-circle.svg?component';
	import ChevronUp from '$lib/assets/icons/chevronUp.svg?component';
	import Heart from '$lib/assets/icons/heart.svg?component';
	import { onMount } from 'svelte';
	import { createQ } from '$lib/stores/tasks/createQ';
	import { getQs, questions } from '$lib/stores/tasks/getQs';
	import Spinner from '$lib/components/common/Spinner.svelte';
	import ColorSelect from '$lib/components/app/ColorSelect.svelte';
	import { color } from '$lib/stores/tasks/colorSelect';

	let expandWindow: boolean = false;
	let newQ: string;
	let pending: boolean = false;

	onMount(async () => {
		await getQs();
	});

	const submit = async () => {
		pending = true;
		// let hue = BigInt($hueStore);
		// console.log('hue is', hue);
		await createQ(newQ, $color).catch((error) => {
			console.log('errorcatch', error);
		});
		pending = false;
		newQ = '';
		getQs();
		//window.setTimeout(() => (expandWindow = false), 1500);
		// 1500ms seems a balanced time for window to retract,
		//this might unconsciously help for the user to lessen Q spamming
	};
</script>

<div class="flex flex-col gap-4">
	<div class="w-full mx-auto flex-col p-2 justify-between">
		<button class="w-full px-3 flex justify-between items-center font-Poppins rounded bg-slate-50 border-slate-600 border"
			on:click={() => (expandWindow = !expandWindow)}
		>
			<span>
				{#if !expandWindow}
					Ask a Yes/No question...
				{/if}
			</span>
			{#if !expandWindow}
				<!-- <ChevronDown class="w-9 cursor-pointerborder-none" /> -->
				<Add class="w-10" />
			{:else if expandWindow}
				<ChevronUp class="w-10" />
			{/if}
		</button>

		{#if expandWindow}
			<div class="rounded-md mt-8 flex flex-col justify-center items-center {$color}">
				<textarea
					id="questionInput"
					class="w-full min-h-fit py-20 bg-transparent rounded outline-none text-4xl placeholder-current text-center {$color}"
					placeholder="Type your Yes/No question here" 
					disabled={pending}
					bind:value={newQ}
				/>
				<ColorSelect />

				<div>
					<button on:click={submit} class="default-btn {$color} flex px-20 items-center my-5">
						{#if pending}
							<Spinner/>
						{:else}
							Submit
							<span class="flex ml-1 w-full">+5&nbsp;<Heart class="allign-middle w-4 h-4 mt-1 fill-{$color} stroke-{$color}" /></span>
						{/if}
					</button>
				</div>
			</div>
		{/if}
	</div>

	{#if $questions && $questions.length > 0}
		{#each $questions as question}
			<Qcard {question} />
		{/each}
	{:else}
		<span class="text-slate-700 mx-auto mt-10"
			>That's all questions for now. Come later to check for new ones.</span
		>
	{/if}
</div>
