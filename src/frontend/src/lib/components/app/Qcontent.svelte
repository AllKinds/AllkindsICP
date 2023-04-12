<script lang="ts">
	import { answerQ } from '$lib/stores/tasks/answerQ';
	import { getQs } from '$lib/stores/tasks/getQs';
	import { skipQ } from '$lib/stores/tasks/skipQ';
	import type { Question } from 'src/declarations/backend/backend.did';
	import Spinner from '../common/Spinner.svelte';
	import PlusCircle from '$lib/assets/icons/plus-circle.svg?component';
	import MinusCircle from '$lib/assets/icons/minus-circle.svg?component';

	export let question: Question;
	var likeWeight = 0;
	let skipPending: boolean = false;
	let answerPending: boolean | undefined = undefined;

	const submitAnswer = async (bool: boolean) => {
		answerPending = bool;
		let answer: boolean = bool;
		let weight = BigInt(likeWeight);
		await answerQ(question.hash, answer, weight)
			.catch((error) => {
				console.log('errorcatch', error);
			})
			.catch((error) => {
				console.log('errorcatch', error);
			})
			.then(async () => {
				answerPending = undefined;
				likeWeight = 0;
				getQs();
			});
	};

	const skipQuestion = async () => {
		skipPending = true;
		await skipQ(question.hash).catch((error) => {
			console.log('errorcatch', error);
		});
		skipPending = false;
		getQs();
	};
</script>

<!-- TODO : fix a minimum height here -->
<div class="2xl:w-9/12 mx-auto h-fit rounded-md flex flex-col justify-center items-center">
	<p class="text-4xl w-fit text-center">
		{question.question}
	</p>
	<!--
		<p class="text-slate-500 text-sm p-0">Created: {fromBigInt(question.created)}</p>
		<p class="text-slate-500 text-sm p-0">By: {question.creater}</p>
		<span>Color: {question.color[0]}</span>
		 -->
	<div class="flex gap-2 my-5">
		<button class="sub-btn" on:click={() => likeWeight--}>
			<MinusCircle />
		</button>
		<span class="mt-2">{likeWeight}</span>
		<button class="sub-btn" on:click={() => likeWeight++}>
			<PlusCircle />
		</button>
	</div>

	<div
		class="w-full flex flex-col md:flex-row justify-center items-center dark:text-slate-500 gap-3"
	>
		<div class="m-0 fancy-btn-border flex h-10 w-36 md:order-last">
			<button
				on:click={() => submitAnswer(true)}
				disabled={skipPending || answerPending}
				class=" fancy-btn w-full flex justify-center items-center"
			>
				<span>
					{#if answerPending == true}
						<Spinner />
					{:else}
						YES
					{/if}
				</span>
			</button>
		</div>

		<div class="m-0 fancy-btn-border flex h-10 w-36">
			<button
				on:click={() => submitAnswer(false)}
				disabled={skipPending || answerPending}
				class="fancy-btn w-full flex justify-center items-center "
			>
				<span>
					{#if answerPending == false}
						<Spinner />
					{:else}
						NO
					{/if}
				</span>
			</button>
		</div>

		<button
			on:click={skipQuestion}
			disabled={skipPending || answerPending}
			class=" md:w-36 flex justify-center sub-btn "
		>
			<span>
				{#if !skipPending}
					skip
				{:else if skipPending}
					<Spinner />
				{/if}
			</span>
		</button>
	</div>

	<!-- OLD wrong way of likeweight, leaving it in just in case
		{#if likePending !== undefined} 
		 
		<p class="text-slate-500 text-sm p-0 my-1">Optionally: Rate how important this is for you.</p>
			<div class="flex gap-2">
				{#each Array(10) as _, index}
				<label class="flex flex-col bg-slate-600 justify-content-center p-1 rounded-md">
					<input type=radio bind:group={likeWeight} value={index + 1}>
					<span class="mx-auto text-slate-500">{index + 1}</span>
				</label>
					
					 
				{/each}
			</div>
		{/if}
-->
</div>
