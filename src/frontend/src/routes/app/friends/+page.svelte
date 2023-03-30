<script lang="ts">
	import UserBanner from '$lib/components/app/UserBanner.svelte';
	import Spinner from '$lib/components/common/Spinner.svelte';
	import { foundFriends, getFriends } from '$lib/stores/tasks/getFriends';
	import { fromNullable, fromNullableDate, fromNullableGender } from '$lib/utilities';
	import type { FriendlyUserMatch } from 'src/declarations/backend/backend.did';
	import { onMount } from 'svelte';
	import Refresh from '$lib/assets/icons/refresh.svg?component';

	let pending: boolean = false;
	let flSize = 0;
  let current = 0;

	const handleFindFriends = async () => {
		pending = true;
		await getFriends().catch((error) => {
			console.log('error while getting friends', error);
		});
		//await function for getting all friendrequests
		pending = false;
		flSize = $foundFriends.length;
	};

  onMount(() => {
    if (!$foundFriends) {
      handleFindFriends();
      console.log("first time load")
    } else {
      flSize = $foundFriends.length;
    }
	});

	
</script>

<div class="flex flex-col gap-4">
	<!-- <div class="fancy-btn-border mx-auto mb-0">
		<button on:click={handleFindFriends} class="fancy-btn">
			{#if pending}
				<Spinner />
			{:else}
				Refresh
			{/if}
		</button>
	</div> -->
	<div class="flex gap-3">
		<button
			on:click={() => (current = 0)}
			class:currentTab={current === 0}
			class="pb-2 text-left hover-color hover-circle"
		>
			My Friends{'('}{flSize > 0 ? flSize : 0}{')'}
		</button>
		<button
			on:click={() => (current = 1)}
			class:currentTab={current === 1}
			class="pb-2 text-left hover-color hover-circle"
		>
			Requests{'('}{flSize > 0 ? flSize : 0}{')'}
		</button>

		<button on:click={handleFindFriends} class="cursor-pointer hover-circle hover-color">
			{#if pending}
				<Spinner />
			{:else}
				<Refresh />
			{/if}
		</button>
	</div>

	<div class="rounded-md flex flex-col gap-y-2">
		{#if $foundFriends && $foundFriends.length > 0}
			{#each $foundFriends as u}
				<UserBanner {u} />
			{/each}
		{:else}
			<span class="text-slate-700">Oops you don't have any friends yet!</span>
			<span class="text-slate-700">
        Try the 
        <a href="/app/connect" class="link">Connect</a> 
        page to find people.
      </span>
		{/if}
	</div>
</div>
