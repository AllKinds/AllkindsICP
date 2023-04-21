<script lang="ts">
	import { user } from '$lib/stores/index';
	import { fromNullableDate, fromNullableGender } from '$lib/utilities';
	import { onMount } from 'svelte';
	import { getQsAnswered, answeredQuestions, myQuestions } from '$lib/stores/tasks/getQsAnswered';
	import Qbanner from '$lib/components/app/Qbanner.svelte';
	import { styleStore } from '$lib/stores/tasks/colorSelect';

	//TODO make this into ultility function
	let current = 0;

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
	});
</script>

<div style={$styleStore} class="flex flex-col gap-4">
	<div class="w-24 h-24 rounded-full border-main bg-sub mx-auto">
		<!-- placeholder profile picture -->
	</div>

	<span
		class="text-4xl z-0 font-semibold mx-auto bg-clip-text text-transparent bg-fancy drop-shadow-[0_0_50px_var(--primary-color)]"
	>
		{$user.username}
	</span>

	<span class="p-0 text-xl mx-auto text-zinc-600">
		{userAge}{userGender}
		<span class="p-0 text-base mx-auto text-zinc-600">{userConnect}</span>
	</span>

	<span class="mx-auto">{userAbout}</span>

	<div class="flex gap-3">
		<button
			on:click={() => (current = 0)}
			class:currentTab={current === 0}
			class="pb-2 text-left hover-color hover-circle"
		>
			My Questions
		</button>
		<button
			on:click={() => (current = 1)}
			class:currentTab={current === 1}
			class="pb-2 text-left hover-color hover-circle"
		>
			All Answered
		</button>
	</div>

	<div class="w-100% rounded-md flex flex-col p-2 md:p-8 gap-2">
		{#if $myQuestions && current == 0}
			{#each $myQuestions as q}
				<Qbanner {q} b={false} />
			{/each}
		{:else if $answeredQuestions && current == 1}
			{#each $answeredQuestions as q}
				<Qbanner {q} b={false} />
			{/each}
		{/if}
	</div>
</div>
