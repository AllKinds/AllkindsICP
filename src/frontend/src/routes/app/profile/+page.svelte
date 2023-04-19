<script lang="ts">
	import { user } from '$lib/stores/index';
	import { fromNullableDate, fromNullableGender } from '$lib/utilities';
	import { onMount } from 'svelte';
	import { getQsAnswered, questionsAnswered } from '$lib/stores/tasks/getQsAnswered';
	import Qbanner from '$lib/components/app/Qbanner.svelte';
	import { styleStore } from '$lib/stores/tasks/colorSelect';

	//TODO make this into ultility function
	let userBirth = fromNullableDate($user.birth[0]);
	let ageMs = Number(new Date()) - Number($user.birth[0]) / 1000000;
	let ageY = Math.floor(ageMs / (1000 * 3600 * 24) / 365);

	let userAge = userBirth ? ageY + ', ' : '';
	let userGender = fromNullableGender($user.gender[0])
		? fromNullableGender($user.gender[0]) + ', '
		: '';
	let userAbout = $user.about[0] ? $user.about[0] : '';
	let userConnect = $user.connect[0] ? $user.connect[0] : '';

	console.log('age', userBirth);
	console.log($user.about[0]);

	onMount(async () => {
		//TODO change into button that then calls answered Q
		await getQsAnswered();
		console.log($questionsAnswered);
	});
</script>

<div class="flex flex-col gap-4">
	<div class="w-24 h-24 rounded-full border-main bg-sub mx-auto">
		<!-- placeholder profile picture -->
	</div>
	<span class="text-4xl font-semibold mx-auto bg-clip-text text-transparent bg-gradient-to-r from-[color:var(--primary-color)] to-[color:var(--secondary-color)] drop-shadow-[0_0_50px_var(--primary-color)]"
	style={$styleStore}>
		{$user.username}
	</span>
	<span class="p-0 text-xl mx-auto text-zinc-600">
		{userAge}{userGender}
		<span class="p-0 text-base mx-auto text-zinc-600">{userConnect}</span>
	</span>

	<span class="mx-auto">{userAbout}</span>

	<!--TODO :  2 buttons to call AnsweredQ and MyCreatedQ -->
	<div class=" w-100% rounded-md flex flex-col p-2 md:p-8 gap-2">
		{#if $questionsAnswered}
			{#each $questionsAnswered as q}
				<!-- REVAMP -->
				<Qbanner {q} b={false}>
					<!-- <svelte:fragment slot="weight">
						
					</svelte:fragment> -->
				</Qbanner>
			{/each}
		{/if}
	</div>
</div>
