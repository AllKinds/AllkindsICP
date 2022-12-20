<script lang="ts">
	import BorderBox from '../common/BorderBox.svelte';

	//I should make the types better here
	export let data: any;
	export let ids: any;
</script>

<div class="grid gap-4 md:gap-6 grid-flow-row grid-cols-1 md:grid-cols-3 justify-around lg:gap-10">
	{#each data as d, i}
		<BorderBox fill="brand-gradient-br">
			<div class="h-full bg-slate-200 rounded-lg" style:background-color={d.color}>
				<div class="h-full bg-slate-100/60 dark:bg-slate-800/80 p-2 lg:p-4 rounded-lg">
					<div class="text-2xl pb-1 md:pb-2 lg:text-3xl w-fit font-medium">
						{#if ids} {i + 1} {/if}
						{#if d.title} {d.title} {/if}
					</div>
					<div class="font-montserrat">
						{d.text}
					</div>
				</div>
			</div>
		</BorderBox>
	{/each}
</div>
