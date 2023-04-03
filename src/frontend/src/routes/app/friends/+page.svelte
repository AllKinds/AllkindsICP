<script lang="ts">
	import UserBanner from '$lib/components/app/UserBanner.svelte';
	import Spinner from '$lib/components/common/Spinner.svelte';
	import { getFriends, friendsApproved, friendsWaiting, friendsRequested } from '$lib/stores/tasks/getFriends';
	import type { FriendlyUserMatch, FriendStatus } from 'src/declarations/backend/backend.did';
	import { onMount } from 'svelte';
	import Refresh from '$lib/assets/icons/refresh.svg?component';

	let pending: boolean = false;
  let fA = 0;
  let fW = 0;
  let fR = 0;
	let current = 0;

	const handleFindFriends = async () => {
		pending = true;
		await getFriends().catch((error) => {
			console.log('error while getting friends', error);
		});
		//await function for getting all friendrequests
		pending = false;
		//flSize = $foundFriends.length;
    fA = $friendsApproved.length;
    fW = $friendsWaiting.length;
    fR = $friendsRequested.length;
    //console.log("sortedApproved test:", $foundFriends)
	};



	onMount(() => {
		handleFindFriends();
		// if (!$friendsApproved || !$friendsWaiting) {
		// 	handleFindFriends();
		// 	console.log('first time load');
		// } else {
		// 	//flSize = $foundFriends.length;
    //   fA = $friendsApproved.length;
    //   fW = $friendsWaiting.length;
    //   fR = $friendsRequested.length;
		// }
	});
</script>

<div class="flex flex-col gap-4">
	<div class="flex gap-3">
		<button
			on:click={() => (current = 0)}
			class:currentTab={current === 0}
			class="pb-2 text-left hover-color hover-circle"
		>
			My Friends{'('}{fA > 0 ? fA : 0}{')'}
		</button>
		<button
			on:click={() => (current = 1)}
			class:currentTab={current === 1}
			class="pb-2 text-left hover-color hover-circle"
		>
			Requests{'('}{fW > 0 ? fW : 0}{')'}
		</button>
    <button
    on:click={() => (current = 2)}
    class:currentTab={current === 2}
    class="pb-2 text-left hover-color hover-circle"
  >
    Send{'('}{fR > 0 ? fR : 0}{')'}
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
		<!-- {#if $foundFriends && $foundFriends.length > 0}
			{#each $foundFriends as u}
        {#if (Object.entries(u.status)[0][0] == "Approved") && (current == 0)}
				  <UserBanner {u}/>
        {:else if (Object.entries(u.status)[0][0] == "Waiting")  && (current == 1)}
          <UserBanner {u}/>
        {/if}        
			{/each} -->

    {#if fA > 0 && current == 0}
      {#each $friendsApproved as u}
        <UserBanner {u}/>
      {/each}
    {:else if fW > 0 && current == 1}
      {#each $friendsWaiting as u}
        <UserBanner {u}/>
      {/each}
    {:else if fR > 0 && current == 2}
      {#each $friendsRequested as u}
        <UserBanner {u}/>
      {/each}
		{:else if current == 0}
			<span class="text-slate-700">Oops you don't have any friends yet!</span>
			<span class="text-slate-700">
				Try the
				<a href="/app/connect" class="link">Connect</a>
				page to find people.
			</span>
		{/if}  <!-- {#if (u.status == statusApproved ) && current == 0}
				<UserBanner {u}/>
        {:else if (u.status == (statusRequested || statusWaiting))  && current == 1}
        <UserBanner {u}/>
        {/if} -->
	</div>
</div>
