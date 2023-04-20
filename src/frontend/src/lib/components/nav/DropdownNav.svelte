<script lang="ts">
	import DarkMode from './DarkMode.svelte';
	import NavBars from '$lib/assets/icons/navBars.svg?component';
	import NavX from '$lib/assets/icons/navX.svg?component';
	import Nav from './Nav.svelte';
	import type { LayoutData } from '../../../routes/$types';
	import { styleStore } from '$lib/stores/tasks/colorSelect';

	let visible: boolean = false;
	export let data: LayoutData | undefined;

	function toggleVissible() {
		visible = !visible;
	}
</script>

<!-- TODO : rethink the nav components as this is almost equal to sidepanelnav.svelte
used for landing -->
<div style={$styleStore} class="flex flex-col items-end">
	<button
		class="mt-2 shrink-0 self-end cursor-pointer hover-circle"
		on:click={toggleVissible}
		on:keydown={toggleVissible}
	>
		{#if !visible}
			<NavBars class="w-8" />
		{:else}
			<NavX class="w-8" />
		{/if}
	</button>

	{#if visible}
		<div on:mouseleave={toggleVissible}>
			<Nav {data} path="#" />
		</div>
	{/if}
</div>
