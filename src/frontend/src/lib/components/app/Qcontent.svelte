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
<div
	class="2xl:w-9/12 mx-auto h-fit rounded-md flex flex-col justify-center items-center text-zinc-900"
>
	<p class="text-4xl w-fit text-center">
		{question.question}
	</p>
	<!--
		<p class="text-slate-500 text-sm p-0">Created: {fromBigInt(question.created)}</p>
		<p class="text-slate-500 text-sm p-0">By: {question.creater}</p>
		<span>Color: {question.color[0]}</span>
		 -->
	<div class="flex gap-2 my-5 items-center">
		<button class="sub-btn" on:click={() => likeWeight--}>
			<MinusCircle />
		</button>
		<span>{likeWeight}</span>
		<button class="sub-btn" on:click={() => likeWeight++}>
			<PlusCircle />
		</button>
	</div>

	<div class="w-full flex flex-row justify-center items-center gap-3">
		<button
			on:click={() => submitAnswer(false)}
			disabled={skipPending || answerPending}
			class="default-btn w-32 flex justify-center items-center "
		>
			<span>
				{#if answerPending == false}
					<Spinner />
				{:else}
					NO
				{/if}
			</span>
		</button>

		<button
			on:click={skipQuestion}
			disabled={skipPending || answerPending}
			class="p-2 flex justify-center sub-btn w-fit"
		>
			<span>
				{#if !skipPending}
					skip
				{:else if skipPending}
					<Spinner />
				{/if}
			</span>
		</button>

		<button
			on:click={() => submitAnswer(true)}
			disabled={skipPending || answerPending}
			class="default-btn w-32 flex justify-center items-center"
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
	
</div>
