<script lang="ts">
	import { user } from '$lib/stores/index';
	import DarkMode from './DarkMode.svelte';
	import LoginBtn from './LoginBtn.svelte';
	import Heart from '$lib/assets/icons/heart.svg?component';
	import { authStore } from '$lib/stores/';
	import { AuthState } from '$lib/stores/types';

	export let data: any;
	export let path: any;
</script>

<!-- border-main if not using fancy bg -->
<div class="bg-fancy rounded-lg w-40 mx-auto p-0.5 border-main">

	<div
		class="flex flex-col bg-main95 rounded-lg trans-300 p-2 text-lg items-start "
	>
		{#if $authStore === AuthState.Registered}
		<!-- bg-clip-text text-transparent bg-fancy  -->
			<span class="font-semibold">
				<a href="/app/profile">{$user.username}</a>
			</span>
			<div class="flex ">
				<span class="mt-0.5 mr-1">
					<Heart />
				</span>
				{$user.points}
			</div>
			<div class="border-main my-2 px-3 w-full" />
		{/if}

		{#if data}
			{#each data.sections as section}
				<a
					class="hover:bg-zinc-300/50 dark:hover:bg-zinc-700/50 w-fit  decoration-transparent rounded-md px-1 flex"
					href="{path}{section.slug}"
				>
					<svelte:component this={section.icon} class="w-6 mr-1 -ml-1" />
					{section.title}
				</a>
			{/each}
			<div class="border-main h-0 my-2 px-3 w-full" />
		{/if}

		<LoginBtn />
		<DarkMode />
	</div>
</div>
