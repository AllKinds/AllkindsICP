<script lang="ts">
	import DarkMode from './DarkMode.svelte';
	import LoginBtn from './LoginBtn.svelte';

	export let data: any;
	export let path: any;
</script>

<div class="rounded-lg p-0.5 bg-gradient-to-br from-DF-blue via-DF-red to-DF-yellow w-40 mx-auto">
	<div
		class="flex flex-col dark:bg-slate-800/95 bg-slate-100 rounded-lg trans-300 p-2 text-lg items-start"
	>
		{#if data}
			{#each data.sections as section}
				<a
					class="hover:bg-slate-300 dark:hover:bg-slate-600 w-fit  decoration-transparent rounded-md px-2 flex"
					href="{path}{section.slug}"
				>
					<svelte:component this={section.icon} class="w-6 mr-1 -ml-1" />
					{section.title}
				</a>
			{/each}
			<div class="h-0.5 my-2 px-3 w-full bg-gradient-to-br from-DF-purple to-DF-orange" />
		{/if}
		<LoginBtn />
		<DarkMode />
	</div>
</div>
