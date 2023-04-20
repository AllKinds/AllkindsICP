<script lang="ts">
	import Qcard from '$lib/components/app/Qcard.svelte';
	import Add from '$lib/assets/icons/plus-circle.svg?component';
	import ChevronUp from '$lib/assets/icons/chevronUp.svg?component';
	import ChevronDown from '$lib/assets/icons/chevronDown.svg?component';
	import Heart from '$lib/assets/icons/heart.svg?component';
	import { onMount } from 'svelte';
	import { createQ } from '$lib/stores/tasks/createQ';
	import { getQs, questions } from '$lib/stores/tasks/getQs';
	import Spinner from '$lib/components/common/Spinner.svelte';
	import { hueStore, styleStore } from '$lib/stores/tasks/colorSelect';
	import { toBigInt } from '$lib/utilities';

	let expandWindow: boolean = false;
	let newQ: string;
	let pending: boolean = false;
	
	onMount(async () => {
		await getQs();
	});

	const submit = async () => {
		pending = true;
		let hue = BigInt($hueStore);
		console.log('hue is', hue)
		await createQ(newQ, hue).catch((error) => {
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

<div style={$styleStore} class="flex flex-col gap-4">
	<div class="border-main bg-sub30 w-full mx-auto flex-col padding py-1 justify-between">
		<button
			class="w-full flex justify-between items-center"
			on:click={() => (expandWindow = !expandWindow)}
		>
			<span class=""> Create a new Yes/No question... </span>

			{#if !expandWindow}
				<!-- <ChevronDown class="w-9 cursor-pointerborder-none" /> -->
				<Add class="w-12 hover-circle" />
			{:else if expandWindow}
				<ChevronUp class="w-12 hover-circle" />
			{/if}
		</button>

		{#if expandWindow}
			<div class="mt-8 flex flex-col justify-center items-center">
				<textarea
					id="questionInput"
					class="inputfield w-full min-h-fit py-20 bg-transparent outline-none text-4xl text-center placeholder-slate-300 dark:placeholder-slate-600"
					placeholder="What would you like to ask?"
					disabled={pending}
					bind:value={newQ}
				/>

				<div class="fancy-btn-border">
					<button on:click={submit} class="fancy-btn flex">
						{#if pending}
							<Spinner />
						{:else}
							Submit
							<span class="flex ml-1 ">+5 <Heart class="w-4 h-4 mt-1" /></span>
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
			>Oops! There are no questions for you to answer at this moment.</span
		>
	{/if}
</div>
