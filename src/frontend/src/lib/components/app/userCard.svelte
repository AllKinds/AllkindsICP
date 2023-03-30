<script lang="ts">
	import { sendFriendRequest } from '$lib/stores/tasks/sendFriendRequest';
	import { fromNullable, fromNullableGender } from '$lib/utilities';
	import type { Principal } from '@dfinity/principal';
	import type { FriendlyUserMatch } from 'src/declarations/backend/backend.did';
	import Spinner from '../common/Spinner.svelte';
	import Qbanner from './Qbanner.svelte';

	export let match: FriendlyUserMatch;

	let pending: boolean = false;
	let succes: boolean = false;
	let userPrincipal: Principal = match.principal;
	let userName = match.username;
	let userScore = match.cohesion;
	let userAbout = fromNullable(match.about);
	let userGender = fromNullableGender(match.gender);
	let userBirth = fromNullable(match.birth);
	//TODO make age utility function
	let ageMs = Number(new Date()) - Number(match.birth) / 1000000;
	let ageY = Math.floor(ageMs / (1000 * 3600 * 24) / 365);
	//TODO : return all questions (+weight) with indication which had common answer (matched)
	let answeredQuestions = match.answeredQuestions;
	let aQsize = answeredQuestions.length;

	const handleConnectionRequest = async () => {
		pending = true;
		succes = false;
		await sendFriendRequest(userPrincipal).catch((err) => {
			console.log('error while sending connection request', err);
		});
		succes = true;
		pending = false;
	};
	//TODO : spinner keeps loading, cant update states after function call? check app/component load states
	//myabe bcs no subscribe value here for comp to update
</script>

<!-- will only show 1 user for now, one with nearest cohesion score
TODO : finish this card, and fix cohesion score in backend for a proper result
TODO : at same time implement this into a friendlist and using same component 
TODO : backend create friendlist and connection request implementation -->

<!-- NOTE: this component sizes according to parent -->
<div class="w-full flex flex-col justify-between mx-auto">
	<div class="w-full h-72 sm:h-96 mx-auto rounded-md bg-sub">
		<!-- placeholder profile picture -->
	</div>

	<div class="p-1 sm:p-2 flex flex-col">
		<div class="flex p-1 text-2xl font-bold justify-between">
			<span>{userName}</span>
			<span>
				{userScore}
				{'(' + aQsize + ')'}
			</span>
		</div>
		<span class="p-1 text-slate-600"
			>{userBirth ? ageY + ', ' : ''}{userGender ? userGender : ''}</span
		>
		<span class="p-1 ">{userAbout ? userAbout : ''}</span>

		{#if succes}
			<span class="mx-auto text-slate-600">Connection request send!</span>
		{:else}
			<div class="mx-auto fancy-btn-border">
				<button on:click={handleConnectionRequest} class="fancy-btn bg-main90">
					{#if pending}
						<Spinner />
					{:else}
						Connect
					{/if}
				</button>
			</div>
		{/if}

		<button class="pb-2 text-left ">
			<span class="hover-bg hover-color">All Questions{'('}{aQsize > 0 ? aQsize : 0}{')'}</span>
		</button>

		{#if aQsize > 0}
			<div class="flex flex-col gap-2">
				{#each answeredQuestions as q}
					<Qbanner {q} />
				{/each}
			</div>
		{/if}
	</div>
</div>
