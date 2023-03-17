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
		let like: LikeKind =
			likeWeight > 0
				? { Like: BigInt(Math.abs(likeWeight)) }
				: { Dislike: BigInt(Math.abs(likeWeight)) };

		const putAnswer = async () =>
			await answerQ(question.hash, answer).catch((error) => {
				console.log('errorcatch', error);
			});

		//TODO : clean up and write more efficient
		if (likeWeight == 0) {
			await putAnswer();
		} else {
			await likeQ(question.hash, like)
				.catch((error) => {
					console.log('errorcatch', error);
				})
				.then(async () => await putAnswer());

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


	<div class="2xl:w-9/12 mx-auto rounded-md flex flex-col justify-center items-center">
		<span class=" text-3xl w-fit text-center">{question.question}</span>
		<!--
		<p class="text-slate-500 text-sm p-0">Created: {fromBigInt(question.created)}</p>
		<p class="text-slate-500 text-sm p-0">By: {question.creater}</p>
		<span>Color: {question.color[0]}</span>
		 -->
		<div class="flex gap-2 my-8">
			<button on:click={() => likeWeight--}>
				<MinusCircle />
			</button>
			<span class="">{likeWeight}</span>
			<button on:click={() => likeWeight++}>
				<PlusCircle />
			</button>
		</div>

		<div
			class="w-full flex flex-col md:flex-row justify-center items-center dark:text-slate-500 pt-3 gap-5"
			>
			
			<div class="hover:fancy-border rounded-full flex h-14 w-3/4 md:w-4/12 grow hover:border-0 border-slate-400 p-0.5 border-2 md:order-last">
					<button
						on:click={() => submitAnswer(true)}
						disabled={skipPending || answerPending}
						class="bg-slate-700 hover:bg-slate-700/90 rounded-full w-full flex justify-center items-center"
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

			<div class="hover:fancy-border rounded-full flex h-14 w-3/4 md:w-4/12 grow hover:border-0 border-slate-400 p-0.5 border-2 ">
				<button
					on:click={() => submitAnswer(false)}
					disabled={skipPending || answerPending}
					class="bg-slate-700 hover:bg-slate-700/90 rounded-full w-full flex justify-center items-center "
				>
					<h3>
						{#if answerPending == undefined}
							NO
						{:else if answerPending == false}
							<Spinner />
						{/if}
					</h3>
				</button>				
			</div>


			<button
				on:click={skipQuestion}
				disabled={skipPending || answerPending}
				class=" md:w-36 flex justify-center hover:text-slate-400 "
			>
				<p class="">
					{#if !skipPending}
						skip
					{:else if skipPending}
						<Spinner />
					{/if}
				</p>
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

