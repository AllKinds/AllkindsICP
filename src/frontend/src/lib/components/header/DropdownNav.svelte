<script lang="ts">
	import DarkMode from './DarkMode.svelte';
	import NavBars from '$lib/assets/icons/navBars.svg?component';
	import NavX from '$lib/assets/icons/navX.svg?component';
	import LoginBtn from '../common/LoginBtn.svelte';

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

	{#if visible}
		<div class="rounded-lg p-0.5 brand-gradient-br" on:mouseleave={toggleVissible}>
			<div
				class="flex flex-col rounded-lg trans-300 bg-slate-100 dark:bg-slate-800 p-2 text-lg items-start "
			>
				{#if links}
					{#each links.sections as section}
						<a
							class="hover:bg-slate-200 dark:hover:bg-slate-600 w-fit  decoration-transparent rounded-md px-2"
							href="{path}{section.slug}">{section.title}</a
						>
					{/each}
					<div class="h-0.5 my-1 w-full bg-gradient-to-br from-DF-purple to-DF-orange" />
				{/if}
				<LoginBtn />
				<DarkMode />
			</div>
		</div>
	{/if}
</div>
