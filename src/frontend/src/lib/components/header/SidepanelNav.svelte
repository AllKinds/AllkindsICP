<script lang="ts">
	import NavBars from '$lib/assets/icons/navBars.svg?component';
	import NavX from '$lib/assets/icons/navX.svg?component';
	import { sidepanelToggle } from '$lib/stores';

	let visible: boolean = false;

	function toggleVissible() {
		visible = !visible;
    sidepanelToggle.set(visible)
	}

  $: { visible && !$sidepanelToggle ? toggleVissible() : null } 
  //above line helps to update hiding sidepanel when user moves out of it
</script>

<div class="flex flex-col items-end">
	<div class="pt-2 shrink-0 self-end " on:click={toggleVissible} on:keydown={toggleVissible}>
		{#if !visible}
			<NavBars class="w-8 m-auto" />
		{:else}
			<NavX class="w-8 m-auto" />
		{/if}
	</div>
</div>