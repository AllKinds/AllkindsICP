<script lang="ts">
	import { user } from '$lib/stores/index';
	import { fromNullableDate, fromNullableGender } from '$lib/utilities';
	import { onMount } from 'svelte';
	import { getQsAnswered, questionsAnswered } from '$lib/stores/tasks/getQsAnswered';

	let userBirth = fromNullableDate($user.birth[0]);
	let ageMs = Number(new Date()) - Number($user.birth[0]) / 1000000;
	let ageY = Math.floor(ageMs / (1000 * 3600 * 24) / 365);

	console.log('age', userBirth);
	console.log($user.about[0]);

	onMount(async () => {
		//TODO change into button that then calls answered Q
		await getQsAnswered();
		console.log($questionsAnswered);
	});
</script>

<div class="flex flex-col gap-4 border-main bg-sub30 py-8">
	<div class="w-24 h-24 rounded-full border-main bg-sub mx-auto">
		<!-- placeholder profile picture -->
	</div>
	<span class=" text-4xl font-semibold mx-auto bg-clip-text text-transparent bg-fancy">
		{$user.username}
	</span>
	<span class="p-0 text-xl mx-auto text-zinc-600">
		<!-- TEMP FIX : check and manually give undefined bcs of date-time issue -->
		{userBirth ? ageY : 'undefined'} , {fromNullableGender($user.gender[0])}
	</span>
	<span class="mx-auto">{$user.about[0] ? $user.about[0] : ''}</span>

	<!--TODO :  2 buttons to call AnsweredQ and MyCreatedQ -->
	<div class=" w-100% rounded-md flex flex-col p-2 md:p-8 gap-2">
		{#if $questionsAnswered}
			{#each $questionsAnswered as q}
				<!--TODO : a more default small question card -->
				<div class="flex bg-sub90 border-main p-4">
					{q.question},
					{q.points},
					{q.creater}
				</div>
			{/each}
		{/if}
	</div>
</div>
