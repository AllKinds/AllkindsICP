<script lang="ts">
	import { user } from '$lib/stores/index';
	import { getMatchedUsers, matchedUsers } from '$lib/stores/tasks/getMatchedUsers';
	import { toNullableGender } from '$lib/utilities';
	import Spinner from '$lib/components/common/Spinner.svelte';
	import Slider from '@bulatdashiev/svelte-slider';
	import type { MatchingFilter, User } from 'src/declarations/backend/backend.did';

	let pending: boolean = false;
	let expandWindow: Boolean = false;
	let ageValue = [0, 150];
	let cohesionValue = [100, 100];
	let genderValue = 'Everyone';
	let matches: Array<[User, BigInt]>;

	//this could be moved to some declaration/constant somewhere else
	let genders = ['Everyone', 'Male', 'Female', 'Other', 'Queer'];

	//TODO : DE-COMPONENT (only what cant be fixed with css), and extract the re-occuring CSS

	//TODO : ageMin and ageMax could be made into a tuple type AgeRange
	const handleFindMatches = async () => {
		pending = true;
		let filter: MatchingFilter = {
			cohesion: BigInt(cohesionValue[0]),
			ageRange: [BigInt(ageValue[0]), BigInt(ageValue[1])],
			gender: toNullableGender(genderValue == 'Everyone' ? '' : genderValue)
		};
		console.log('filter obj ready: ', filter);

		await getMatchedUsers(filter).catch((error) => {
			console.log('error while getting matchedUsers', error);
		});
		matches = $matchedUsers;
		console.log($matchedUsers, matches);
		pending = false;
	};
</script>

<div class="flex flex-col gap-2">
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
		class="w-full flex justify-between items-center text-slate-600 hover:text-slate-500"
		on:click={() => (expandWindow = !expandWindow)}
	>
		<span class="text-md font-semibold mx-auto">Change search parameters</span>
	</button>

	{#if expandWindow}
		<div class="w-full md:w-2/3 mx-auto flex flex-col md:flex-row gap-2 justify-center">
			<!-- TODO check sourceCode sliders, as they clip over main nav -->
			<div class="md:w-5/12 flex flex-col bg-slate-700/20 p-2 rounded-md gap-2">
				<span class="text-md font-semibold text-slate-500 mx-auto">Age</span>
				<span class="mx-auto">{ageValue[0]} - {ageValue[1]} year</span>
				<Slider min="0" max="150" step="1" bind:value={ageValue} range order />
			</div>

			<div class="md:w-5/12 flex flex-col bg-slate-700/20 p-2 rounded-md gap-2">
				<span class="text-md font-semibold text-slate-500 mx-auto">Cohesion</span>
				<span class="mx-auto">{cohesionValue[0]}%</span>
				<Slider bind:value={cohesionValue} />
			</div>

			<!-- TODO : gender options, make like profile settings
      + make global declarations for let genders = ['', 'Male', 'Female', 'Other', 'Queer'];
      + label and for each for reoccuring code -->
			<div class="md:w-5/12 flex flex-col bg-slate-700/20 p-2 rounded-md gap-2">
				<span class="text-md font-semibold text-slate-500 mx-auto">Gender</span>
				<div class="grid grid-cols-2 gap-2">
					{#each genders as gender}
						<button
							class="subtleBtn first:col-span-2 "
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

	<div class="dark:bg-slate-700 bg-slate-100 w-100% rounded-md flex flex-col p-2 md:p-8 gap-2 mt-8">
		{#if matches}
			{#each matches as match}
				<!-- TODO make userCard component -->
				<div>
					{match[0].username}
					{match[1]}
				</div>
			{/each}
		{/if}
	</div>
</div>
