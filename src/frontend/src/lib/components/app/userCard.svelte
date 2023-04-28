<script lang="ts">
	import { sendFriendRequest } from '$lib/stores/tasks/sendFriendRequest';
	import { fromNullable, fromNullableGender } from '$lib/utilities';
	import type { Principal } from '@dfinity/principal';
	import type { FriendlyUserMatch } from 'src/declarations/backend/backend.did';
	import PlaceholderPic from '$lib/assets/icons/placeholder-pic.svg?component';
	import Spinner from '../common/Spinner.svelte';
	import Qbanner from './Qbanner.svelte';

	export let match: FriendlyUserMatch;

	let pending: boolean = false;
	let succes: boolean = false;
	let current = 0;

	let userPrincipal: Principal = match.principal;
	let userName = match.username;
	let userScore = match.cohesion;
	let userAbout = match.about;
	let userGender = fromNullableGender(match.gender);
	let userBirth = match.birth;
	//TODO make age utility function
	let ageMs = Number(new Date()) - Number(match.birth) / 1000000;
	let ageY = Math.floor(ageMs / (1000 * 3600 * 24) / 365);
	//TODO : return all questions (+weight) with indication which had common answer (matched)
	let answered = match.answered;
	let uncommon = match.uncommon;
	let aQsize = answered.length;
	let uQsize = uncommon.length;

	const handleConnectionRequest = async () => {
		pending = true;
		succes = false;
		await sendFriendRequest(userPrincipal).catch((err) => {
			console.log('error while sending connection request', err);
		});
		succes = true;
		pending = false;
	};
</script>

<!-- NOTE: this component sizes according to parent -->
<div class="w-full flex flex-col justify-between mx-auto">
	<div class="w-full h-72 sm:h-96 mx-auto rounded-md bg-sub overflow-clip">
		<PlaceholderPic class=" h-56 sm:h-72 mx-auto mt-24"/>
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
			<span class="mx-auto text-slate-600 py-8">Connection request send!</span>
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
		<div>
			<button
				class="pb-2 text-left hover-color hover-circle"
				on:click={() => (current = 0)}
				class:currentTab={current === 0}
			>
				<span class="hover-bg hover-color">All Questions{'('}{aQsize > 0 ? aQsize : 0}{')'}</span>
			</button>
			<button
				class="pb-2 text-left hover-color hover-circle"
				on:click={() => (current = 1)}
				class:currentTab={current === 1}
			>
				<span class="hover-bg hover-color">Find out{'('}{uQsize > 0 ? uQsize : 0}{')'}</span>
			</button>
		</div>

		<div class="flex flex-col gap-2 mt-3">
			{#if aQsize > 0 && current == 0}
				{#each answered as a}
					<Qbanner q={a[0]} b={a[1]} />
				{/each}
			{:else if uQsize > 0 && current == 1}
				{#each uncommon as u}
					<Qbanner q={u} b={false} />
				{/each}
			{/if}
		</div>
	</div>
</div>
