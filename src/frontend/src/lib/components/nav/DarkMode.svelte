<script lang="ts">
	import { onMount } from 'svelte';
	import Sun from '$lib/assets/icons/sun.svg?component';
	import Moon from '$lib/assets/icons/moon.svg?component';

	let darkMode: any;
	let darkModeReady = false;

	onMount(() => {
		darkMode = document.documentElement.classList.contains('dark');
		darkModeReady = true;
	});
</script>

{#if darkModeReady}
	<span class="toggle mr-1 px-2 pt-2">
		<input
			type="checkbox"
			id="toggle"
			bind:checked={darkMode}
			on:change={() => document.documentElement.classList.toggle('dark')}
		/>
		<label id="darkicon" title="Toggle dark mode" for="toggle" class="p-0.5">
			{#if darkMode}
				<Sun />
			{:else}
				<Moon class="ml-5 h-5 "/>
			{/if}
		</label>
	</span>
{/if}

<style style lang="postcss">
	.toggle input[type='checkbox'] {
		display: none;
	}
	.toggle label {
		@apply inline-block cursor-pointer relative transition-all ease-in-out duration-300 w-12 h-6 rounded-3xl border border-solid border-gray-700 bg-slate-200;
	}
	.toggle label::after {
		content: attr(data-dark);
		@apply flex items-center justify-center rounded-full cursor-pointer absolute top-px left-px transition-all ease-in-out duration-300 w-5 h-5 bg-transparent align-middle;
	}
	.toggle input[type='checkbox']:checked ~ label {
		@apply bg-slate-700;
	}
</style>
