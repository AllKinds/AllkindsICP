<script lang="ts">
	import Layout from '$lib/components/common/Layout.svelte';
	import type { LayoutData } from './$types';
	import DropdownNav from '$lib/components/nav/DropdownNav.svelte';
	import { goto } from '$app/navigation';
	import Nav from '$lib/components/nav/Nav.svelte';

	export let data: LayoutData;
	// layout is actually not needed because landing is a single page, but still using it for possible future additions
</script>

<Layout>
	<svelte:fragment slot="logo">
		<button class="logo" on:click={() => goto('/landing')}>Allkinds</button>
	</svelte:fragment>
	<svelte:fragment slot="nav">
		<DropdownNav {data} />
	</svelte:fragment>
	<svelte:fragment slot="main">
		<div class="flex flex-row justify-center mt-8 gap-4">

			<!-- main content -->
			<div class=" h-fit w-full mt-1 min-h-screen">
				<slot />
			</div>

			<div class="bg-main sticky top-16 h-fit w-44 mx-auto max-lg:hidden rounded-lg">
				<Nav {data} path="" />
			</div>
		</div>
	</svelte:fragment>

</Layout>
