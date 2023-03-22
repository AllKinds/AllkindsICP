<script lang="ts">
	import { fromNullable, fromNullableGender } from '$lib/utilities';
	import type { User, UserMatch } from 'src/declarations/backend/backend.did';
	import Spinner from '../common/Spinner.svelte';
	//export let match: [User, BigInt];
	export let match: UserMatch;
	let pending: boolean = false;

	let userName = match.username;
	let userScore = match.score;
	let userAbout = fromNullable(match.about);
	let userGender = fromNullableGender(match.gender);
	let userBirth = fromNullable(match.birth);
	let ageMs = Number(new Date()) - Number(match.birth) / 1000000;
	let ageY = Math.floor(ageMs / (1000 * 3600 * 24) / 365);

	//TODO : change backend so it doesn't return a User obj,
	//let it return the values that according user has made init public viewable

	const handleConnectionRequest = async () => {};
</script>

<!-- will only show 1 user for now, one with nearest cohesion score
TODO : finish this card, and fix cohesion score in backend for a proper result
TODO : at same time implement this into a friendlist and using same component 
TODO : backend create friendlist and connection request implementation -->

<div class="sm:w-96 border-main flex flex-col justify-between">
	<div class="w-full h-64 sm:h-96 mx-auto rounded-md bg-sub">
		<!-- placeholder profile picture -->
	</div>
	<div class="p-1 sm:p-2 flex flex-col">
		<div class="flex p-1 text-2xl font-bold justify-between">
			<span>{userName}</span>
			<span>{userScore}{'%(' + userScore + ')'}</span>
		</div>
		<span class="p-1 text-slate-600"
			>{userBirth ? ageY + ', ' : ''}{userGender ? userGender : ''}</span
		>
		<span class="p-1 ">{userAbout ? userAbout : ''}</span>

		<div class="mx-auto fancy-btn-border">
			<button on:click={handleConnectionRequest} class="fancy-btn bg-main90">
				{#if pending}
					<Spinner />
				{:else}
					Request contact
				{/if}
			</button>
		</div>

		<div class="h-10" />
	</div>

	<!-- create and implement a Connection Request btn only when used from /home -->
</div>
