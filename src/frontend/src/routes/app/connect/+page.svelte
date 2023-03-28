<script lang="ts">
	import { user } from '$lib/stores/index';
	import { getMatchedUser, matchedUser } from '$lib/stores/tasks/getMatchedUser';
	import { toNullableGender } from '$lib/utilities';
	import Spinner from '$lib/components/common/Spinner.svelte';
	import Slider from '@bulatdashiev/svelte-slider';
	import type { MatchingFilter, User, UserMatch } from 'src/declarations/backend/backend.did';
	import UserCard from '$lib/components/app/UserCard.svelte';

	let pending: boolean = false;
	let expandWindow: Boolean = false;
	//age + cohes based on Slider plugin, see for more info
	let ageValue = [0, 150];
	let cohesionValue = [100, 100];
	let genderValue = 'Everyone';
	//let matches: Array<[User, BigInt]>;
	let match: UserMatch;

	//this could be moved to some declaration/constant somewhere else
	let genders = ['Everyone', 'Male', 'Female', 'Other', 'Queer'];

	//TODO : DE-COMPONENT-IALIZE (only what cant be fixed with css classes), and extract the re-occuring CSS

	const handleFindMatches = async () => {
		pending = true; 
		let filter: MatchingFilter = {
			cohesion: BigInt(cohesionValue[0]),
			ageRange: [BigInt(ageValue[0]), BigInt(ageValue[1])],
			gender: toNullableGender(genderValue == 'Everyone' ? '' : genderValue)
		};
		console.log('filter obj ready: ', filter);

		await getMatchedUser(filter).catch((error) => {
			console.log('error while getting matchedUsers', error);
		});
		//matches = $matchedUsers;
		//console.log($matchedUsers, matches);
		match = $matchedUser;
		console.log($matchedUser, match);
		pending = false;
	};
</script>

<div class="flex flex-col gap-2 border-main bg-sub30 py-8">
	<div class="fancy-btn-border mx-auto mb-0">
		<button on:click={handleFindMatches} class="fancy-btn">
			{#if pending}
				<Spinner />
			{:else}
				Find a new connection
			{/if}
		</button>
	</div>
	<button
		class="w-full flex justify-between items-center hover-color"
		on:click={() => (expandWindow = !expandWindow)}
	>
		<span class="text-md hover-color font-semibold mx-auto">Change search parameters</span>
	</button>

	{#if expandWindow}
		<div class="w-full p-4 md:w-2/3 mx-auto flex flex-col md:flex-row gap-2 justify-center">
			<!-- TODO check sourceCode sliders, as they clip over main nav -->
			<div class="filter-box">
				<span class="filter-name">Age</span>
				<span class="mx-auto">{ageValue[0]} - {ageValue[1]} year</span>
				<Slider min="0" max="150" step="1" bind:value={ageValue} range order />
			</div>

			<div class="filter-box">
				<span class="filter-name">Cohesion</span>
				<span class="mx-auto">{cohesionValue[0]}%</span>
				<Slider bind:value={cohesionValue} />
			</div>

			<!-- TODO : gender options, make like profile settings
      + make global declarations for let genders = ['', 'Male', 'Female', 'Other', 'Queer'];
      + label and for each for reoccuring code -->
			<div class="filter-box">
				<span class="filter-name">Gender</span>
				<div class="grid grid-cols-2 gap-2">
					{#each genders as gender}
						<button
							class="hover:bg-zinc-500 border-main first:col-span-2 "
							class:active={genderValue === gender}
							on:click={() => (genderValue = gender)}
						>
							{gender}
						</button>
					{/each}
				</div>
			</div>
		</div>
	{/if}

	<div class="rounded-md flex flex-col mx-auto">
		{#if match}
			<!-- {#each matches as match} -->
			<UserCard {match} />
			<!-- {/each} -->
		{/if}
	</div>
</div>
