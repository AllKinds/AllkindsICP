<script lang="ts">
	import NavBars from '$lib/assets/icons/navBars.svg?component';
	import NavX from '$lib/assets/icons/navX.svg?component';
	import Nav from './Nav.svelte';
	import type { LayoutData } from '../../../routes/$types';
	import { styleStore } from '$lib/stores/tasks/colorSelect';

	let visible: boolean = false;
	export let data: LayoutData;

	function toggleVissible() {
		visible = !visible;
	}
</script>

<div style={$styleStore} class="flex flex-col items-end h-screen">
	<button
		class="mt-2 shrink-0 self-end lg:hidden hover-circle cursor-pointer"
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
		<div class="px-4 fixed h-screen right-0 top-14 top bg-main" on:mouseleave={toggleVissible}>
			<Nav {data} path="" />
		</div>
	{/if}
</div>
