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

	const handleFindFriends = async () => {
		pending = true;
		await getFriends().catch((error) => {
			console.log('error while getting friends', error);
		});
    //await function for getting all friendrequests
		pending = false;
    flSize = $foundFriends.length;
	};
  
  onMount(async () => {
		//TODO change into button that then calls answered Q
		if ($foundFriends) {
      flSize = $foundFriends.length;
    };
	});

let current = 0;

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
    <button on:click={() => current = 0} class:currentTab={current === 0} class="pb-2 text-left hover-color hover-circle">
      <span class="">
        My Friends{'('}{flSize > 0 ? flSize : 0}{')'}
      </span>
    </button>
    <button on:click={() => current = 1} class:currentTab={current === 1} class="pb-2 text-left hover-color hover-circle">
      <span class="">
        Requests{'('}{flSize > 0 ? flSize : 0}{')'}
      </span>
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
		{#if $foundFriends}
			{#each $foundFriends as u}
        <UserBanner {u}/>
			{/each}
		{/if}
	</div>
</div>
