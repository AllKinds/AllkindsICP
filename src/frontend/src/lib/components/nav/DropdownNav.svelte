<script lang="ts">
	import DarkMode from './DarkMode.svelte';
	import NavBars from '$lib/assets/icons/navBars.svg?component';
	import NavX from '$lib/assets/icons/navX.svg?component';
	import Nav from './Nav.svelte';
	import type { LayoutData } from '../../../routes/$types';

	let visible: boolean = false;
	export let data: LayoutData | undefined;

	function toggleVissible() {
		visible = !visible;
	}
</script>

<div class="flex flex-col items-end">
	<button class="pt-2 shrink-0 self-end hover:cursor-pointer" on:click={toggleVissible} on:keydown={toggleVissible}>
		{#if !visible}
			<NavBars class="w-8 m-auto" />
		{:else}
			<NavX class="w-8 m-auto" />
		{/if}
	</button>

	{#if visible}
		<div on:mouseleave={toggleVissible}>
			<Nav {data} path="#" />
		</div>
	{/if}
</div>
