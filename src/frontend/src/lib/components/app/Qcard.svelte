<script lang="ts">
	import { answerQ } from '$lib/stores/tasks/answerQ';
	import { getQs } from '$lib/stores/tasks/getQs';
	import { skipQ } from '$lib/stores/tasks/skipQ';
	import { fromBigInt } from '$lib/utilities';
	import type { AnswerKind, Question } from 'src/declarations/backend/backend.did';
	import Spinner from '../common/Spinner.svelte';

	export let question: Question;
	let skipPending: boolean = false;
	let answerPending: boolean | undefined = undefined;

	const submitAnswer = async (bool: boolean) => {
		answerPending = bool;
		let answer: AnswerKind = { Bool: bool };
		await answerQ(question.hash, answer)
			.catch((error) => {
				console.log('errorcatch', error)
			})
		answerPending = undefined;
		getQs();
	};

	const skipQuestion = async () => {
		skipPending = true;
		await skipQ(question.hash)
			.catch((error) => {
				console.log('errorcatch', error)
			})
		skipPending = false;
		getQs();
	};
</script>

<div
	class="odd:dark:bg-slate-700 even:dark:bg-slate-700/50 odd:bg-slate-100 even:bg-slate-200/50 dark:border-none w-full border  p-2 md:p-3 lg:p-5"
>
	<div class="2xl:w-9/12 mx-auto rounded-md flex flex-col justify-center items-center">
		<h2 class=" w-fit">{question.question}</h2>
		<p class="text-slate-500 text-sm p-0">Created: {fromBigInt(question.created)}</p>
		<!-- <span>Hash: {question.hash}</span>
  <span>Color: {question.color[0]}</span> -->
		<!--   -->
		<div
			class="w-full flex flex-row justify-center items-center dark:text-slate-700 pt-3 gap-2 md:gap-4"
		>
			<button
				on:click={() => submitAnswer(true)}
				disabled={skipPending || answerPending}
				class="transition-all bg-green-400 hover:bg-green-500 h-16 w-4/12 rounded-xl flex justify-center items-center grow"
			>
				<h3>
					{#if answerPending == true}
						<Spinner />
					{:else}
						YES
					{/if}
				</h3>
			</button>
			<button
				on:click={skipQuestion}
				disabled={skipPending || answerPending}
				class="transition-all dark:bg-slate-600 h-16 w-16 md:w-36 rounded-xl dark:hover:bg-slate-800/70 bg-slate-200 hover:bg-slate-300 flex justify-center items-center"
			>
				<p class=" text-slate-400">
					{#if !skipPending}
						skip
					{:else if skipPending}
						<Spinner />
					{/if}
				</p>
			</button>
			<button
				on:click={() => submitAnswer(false)}
				disabled={skipPending || answerPending}
				class="transition-all bg-red-400 hover:bg-red-500 h-16 w-4/12 rounded-xl flex justify-center items-center grow"
			>
				<h3>
					{#if answerPending == false}
						<Spinner />
					{:else}
						NO
					{/if}
				</h3>
			</button>
		</div>
	</div>
</div>
