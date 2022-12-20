<script lang="ts">
	import NavBars from '$lib/assets/icons/navBars.svg?component';
	import NavX from '$lib/assets/icons/navX.svg?component';
	import BorderBox from '../common/BorderBox.svelte';
	import LoginBtn from '../common/LoginBtn.svelte';
	import DarkMode from './DarkMode.svelte';

	let visible: boolean = false;
	export let links: any;
	export let path: any;

	function toggleVissible() {
		visible = !visible;
	}
</script>

<div class="flex flex-col items-end">
	<div class="pt-2 shrink-0 self-end " on:click={toggleVissible} on:keydown={toggleVissible}>
		{#if !visible}
			<NavBars class="w-8 m-auto" />
		{:else}
			<NavX class="w-8 m-auto" />
		{/if}
	</div>

	<!-- <div 
		class="" 
		hidden={!$sidepanelToggle}
		on:mouseleave={ () => sidepanelToggle.set(!$sidepanelToggle) } 
	> -->

	
	{#if visible}
		<div class="pt-12 dark:bg-slate-900 bg-slate-200 p-3 h-screen  w-52 fixed right-0 "on:mouseleave={toggleVissible}>
			<BorderBox fill="brand-gradient-br">
			<div
				class="flex flex-col dark:bg-slate-800/95 bg-slate-100/95 rounded-lg trans-300 p-2 text-lg items-start  "
			>
				{#if links}
					{#each links.sections as section}
						<a
							class="hover:bg-slate-300 dark:hover:bg-slate-600 w-fit  decoration-transparent rounded-md px-2"
							href="{path}{section.slug}">{section.title}</a
						>
					{/each}
					<div class="h-0.5 my-2 px-3 w-full bg-gradient-to-br from-DF-purple to-DF-orange" />
				{/if}
					<LoginBtn />
					<DarkMode />
			</div>
		</BorderBox>
		</div>
	{/if}
</div>