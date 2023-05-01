<script lang="ts">
	import UserBanner from '$lib/components/app/UserBanner.svelte';
	import {
		getFriends,
		friendsApproved,
		friendsWaiting,
		friendsRequested
	} from '$lib/stores/tasks/getFriends';
	import { onMount } from 'svelte';

	let pending: boolean = false;
	let current = 0;

	const handleFindFriends = async () => {
		pending = true;
		await getFriends().catch((error) => {
			console.log('error while getting friends', error);
		});
		pending = false;
	};

	$: fA = $friendsApproved ? $friendsApproved.length : 0;
	$: fW = $friendsWaiting ? $friendsWaiting.length : 0;
	$: fR = $friendsRequested ? $friendsRequested.length : 0;

	onMount(() => {
		handleFindFriends();
	});
</script>

<div class="flex flex-col gap-4">

	<div class="flex gap-3">
		<button
			on:click={() => (current = 0)}
			class:currentTab={current === 0}
			class="pb-2 text-left hover-color hover-circle"
		>
			My Friends{'('}{fA > 0 ? fA : 0}{')'}
		</button>
		<button
			on:click={() => (current = 1)}
			class:currentTab={current === 1}
			class="pb-2 text-left hover-color hover-circle"
		>
			Requests{'('}{fW > 0 ? fW : 0}{')'}
		</button>
		<button
			on:click={() => (current = 2)}
			class:currentTab={current === 2}
			class="pb-2 text-left hover-color hover-circle"
		>
			Send{'('}{fR > 0 ? fR : 0}{')'}
		</button>
	</div>

	<div class="rounded-md flex flex-col gap-y-2">
		{#if fA > 0 && current == 0}
			{#each $friendsApproved as match}
				<UserBanner {match} />
			{/each}
		{:else if fW > 0 && current == 1}
			{#each $friendsWaiting as match}
				<UserBanner {match} />
			{/each}
		{:else if fR > 0 && current == 2}
			{#each $friendsRequested as match}
				<UserBanner {match} />
			{/each}
		{:else if current == 0}
			<span class="text-slate-700">Oops you don't have any friends yet!</span>
			<span class="text-slate-700">
				Try the
				<a href="/app/connect" class="link">Connect</a>
				page to find people.
			</span>
		{/if}
	</div>

</div>
