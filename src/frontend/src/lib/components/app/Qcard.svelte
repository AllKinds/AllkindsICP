<script lang="ts">
	import { user } from '$lib/stores/index';
	import { answerQ } from '$lib/stores/tasks/answerQ';
	import { getQs } from '$lib/stores/tasks/getQs';
	import { skipQ } from '$lib/stores/tasks/skipQ';
	import { likeQ } from '$lib/stores/tasks/likeQ';
	import { fromBigInt } from '$lib/utilities';
	import type { AnswerKind, LikeKind, Question } from 'src/declarations/backend/backend.did';
	import Spinner from '../common/Spinner.svelte';
	import PlusCircle from '$lib/assets/icons/plus-circle.svg?component';
	import MinusCircle from '$lib/assets/icons/minus-circle.svg?component';

	export let question: Question;
	let likeWeight: number = 0;
	let skipPending: boolean = false;
	let answerPending: boolean | undefined = undefined;


	const submitAnswer = async (bool: boolean) => {
		answerPending = bool;	
		let answer: AnswerKind = { Bool: bool };
		let like: LikeKind = bool ? { Like: BigInt(likeWeight) } : { Dislike: BigInt(likeWeight) };

		const putAnswer = async () => await answerQ(question.hash, answer).catch((error) => {
			console.log('errorcatch', error);	
			
		});

			//TODO : clean up and write more efficient
		if (likeWeight == 0) {
			await putAnswer();
		} else {
			if (($user.points - BigInt(likeWeight)) >= 0 ) {
				await likeQ(question.hash, like).catch((error) => {
					console.log('errorcatch', error);
					console.log('points - like', $user.points - BigInt(likeWeight));
				}).then(async () => await putAnswer(

				))
			}
			//TODO : show errors on questions correctly
		}

		answerPending = undefined;
		likeWeight = 0;
		getQs();
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

<div
	class="odd:dark:bg-slate-700 even:dark:bg-slate-700/50 odd:bg-slate-100 even:bg-slate-200/50 dark:border-none w-full border  p-2 md:p-3 lg:p-5"
>
	<div class="2xl:w-9/12 mx-auto rounded-md flex flex-col justify-center items-center">
		<h2 class=" w-fit">{question.question}</h2>
		<!--
		<p class="text-slate-500 text-sm p-0">Created: {fromBigInt(question.created)}</p>
		<p class="text-slate-500 text-sm p-0">By: {question.creater}</p>
		<span>Color: {question.color[0]}</span>
		 -->
		<div class="flex gap-2">
			<button on:click={() => likeWeight--}>
				<MinusCircle />
			</button>
			<span class="">{likeWeight}</span>
			<button on:click={() => likeWeight++}>
				<PlusCircle />
			</button>
		</div>

		<div
			class="w-full flex flex-row justify-center items-center dark:text-slate-700 pt-3 gap-2 md:gap-4"
		>
			<!-- button sets likePending status after first click, second click submits the answer value and optionally the like value -->
			<!-- OLD onclick event: on:click={() => likePending == false ? submitAnswer(false) : likePending = false} -->
			<button
				on:click={() => submitAnswer(false)}
				disabled={skipPending || answerPending}
				class="transition-all bg-red-400 hover:bg-red-500 h-16 w-4/12 rounded-xl flex justify-center items-center grow"
			>
				<h3>
					{#if answerPending == undefined}
						NO
					{:else if answerPending == false}
						<Spinner />
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
				on:click={() => submitAnswer(true)}
				disabled={skipPending || answerPending}
				class="transition-all bg-green-400 hover:bg-green-500 h-16 w-4/12 rounded-xl flex justify-center items-center grow"
			>
				<h3>
					{#if answerPending == undefined}
						YES
					{:else if answerPending == true}
						<Spinner />
					{/if}
				</h3>
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
</div>
