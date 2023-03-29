<script lang="ts">
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
				<!-- TODO have different column for non-approved friends -->
				<div class="flex bg-sub90 border-main p-4">
					<div>
						<h2>{friend.username}</h2>
						<span>
							<!-- {Number(fromNullable(friend.birth)) / 1000000} -->
							,{fromNullableGender(friend.gender)}
							,{fromNullable(friend.about)}
						</span>
					</div>
					<div>
						{friend.cohesion}
						{'(' + friend.answeredQuestions.length + ')'}
					</div>
					<!-- <span>Friend status : {friend.status}</span> -->
				</div>
			{/each}
		{/if}
	</div>
</div>
