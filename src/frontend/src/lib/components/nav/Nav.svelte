<script lang="ts">
	import { user } from '$lib/stores/index';
	import DarkMode from './DarkMode.svelte';
	import LoginBtn from './LoginBtn.svelte';
	import Heart from '$lib/assets/icons/heart.svg?component';
	import { authStore } from '$lib/stores/';
	import { AuthState } from '$lib/stores/types';
	import ColorSelect from './ColorSelect.svelte';
	import { styleStore } from '$lib/stores/tasks/colorSelect';

	export let data: any;
	export let path: any;
</script>

<!-- border-main if not using fancy bg -->
<!--  shadow-sm shadow-[color:var(--primary-color)]-->
<div
	class="
	bg-gradient-to-br from-[color:var(--primary-color)] to-[color:var(--secondary-color)] 
	rounded-lg w-40 mx-auto p-[1px]
	drop-shadow-[0_0_5px_var(--glow-color)]
"
>
	<div class="flex flex-col bg-main rounded-lg trans-300 p-2 text-lg items-start ">
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
			<div class="border-main h-0.5 my-2 px-3 w-full" />
		{/if}

		{#if data}
			{#each data.sections as section}
				<a
					class="hover:bg-sub w-fit decoration-transparent rounded-md p-1 flex"
					href="{path}{section.slug}"
				>
					<svelte:component this={section.icon} class="w-6 mr-1 -ml-1" />
					{section.title}
				</a>
			{/each}
			<div class="border-main h-0.5 my-2 px-3 w-full" />
		{/if}

		<LoginBtn />
		<DarkMode />
		<ColorSelect />
	</div>
</div>
