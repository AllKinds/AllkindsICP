<script lang="ts">
	import Spinner from '$lib/components/common/Spinner.svelte';
	import type { Friend } from 'src/declarations/backend/backend.did';
	import { foundFriends, getFriends } from '$lib/stores/tasks/getFriends';

	let pending: boolean = false;
	//let friends: Array<[Friend]>  = $foundFriends;

	const handleFindFriends = async () => {
		pending = true;
		await getFriends().catch((error) => {
			console.log('error while getting friends', error);
		});
		//friends = $foundFriends;
		pending = false;
	};
</script>

<div class="flex flex-col gap-2 border-main bg-sub30 py-8">
	<div class="fancy-btn-border mx-auto mb-0">
		<button on:click={handleFindFriends} class="fancy-btn">
			{#if pending}
				<Spinner />
			{:else}
				My friends
			{/if}
		</button>
	</div>

	<div class="rounded-md flex flex-col mx-auto">
		{#if $foundFriends}
			{#each $foundFriends as friend}
				<div>
					<span>{friend.account}</span>
					<span>{friend.status[0]}</span>
				</div>
			{/each}
		{/if}
	</div>
</div>
