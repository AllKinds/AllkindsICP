<script lang="ts">
	import NavBars from '$lib/assets/icons/navBars.svg?component';
	import NavX from '$lib/assets/icons/navX.svg?component';
	import Nav from './Nav.svelte';
	import type { LayoutData } from '../../../routes/$types';

	let visible: boolean = false;
	export let data: LayoutData;

	function toggleVissible() {
		visible = !visible;
	}
</script>

<div class="flex flex-col items-end">
	<div
		class="pt-2 shrink-0 self-end xl:hidden"
		on:click={toggleVissible}
		on:keydown={toggleVissible}
	>
		{#if !visible}
			<NavBars class="w-8 m-auto" />
		{:else}
			<NavX class="w-8 m-auto" />
		{/if}
	</div>

	{#if visible}
		<div
			class="pt-12 dark:bg-slate-900 bg-neutral-100 p-3 h-screen fixed right-0 "
			on:mouseleave={toggleVissible}
		>
			<Nav {data} path="" />
		</div>
	{/if}
</div>
