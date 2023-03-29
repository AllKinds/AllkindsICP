<script lang="ts">
	import UserBanner from '$lib/components/app/UserBanner.svelte';
	import Spinner from '$lib/components/common/Spinner.svelte';
	import { foundFriends, getFriends } from '$lib/stores/tasks/getFriends';
	import { fromNullable, fromNullableDate, fromNullableGender } from '$lib/utilities';

	let pending: boolean = false;

	//TODO : make utility birth to age calc frontend function to insert in html

	// let userBirth = fromNullable(match.birth);
	// let ageMs = Number(new Date()) - Number(match.birth) / 1000000;
	// let ageY = Math.floor(ageMs / (1000 * 3600 * 24) / 365);

	const handleFindFriends = async () => {
		pending = true;
		await getFriends().catch((error) => {
			console.log('error while getting friends', error);
		});
		pending = false;
	};
</script>

<div class="flex flex-col gap-4">
	<div class="fancy-btn-border mx-auto mb-0">
		<button on:click={handleFindFriends} class="fancy-btn">
			{#if pending}
				<Spinner />
			{:else}
				My friends
			{/if}
		</button>
	</div>

	<div class="rounded-md flex flex-col gap-y-2">
		{#if $foundFriends}
			{#each $foundFriends as u}
        <UserBanner {u}/>
			{/each}
		{/if}
	</div>
</div>
