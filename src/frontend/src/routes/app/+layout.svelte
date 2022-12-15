<script lang="ts">
	import type { LayoutData } from './$types';
	import Layout from '$lib/components/common/Layout.svelte';
	import DropdownNav from '$lib/components/header/DropdownNav.svelte';
	import NavButton from '$lib/components/header/NavButton.svelte';
	import { logout, syncAuth } from '$lib/stores/tasks';
	import { onMount } from 'svelte';
	
	export let data: LayoutData;




	// onMount( () => {
	// 	syncAuth()
	// })
</script>

<Layout>
	<svelte:fragment slot="nav">
		<DropdownNav links={data} path="/app/">
			<NavButton on:click={logout}>logout</NavButton>
		</DropdownNav>
	</svelte:fragment>

	<svelte:fragment slot="main">
		<slot />
	</svelte:fragment>
</Layout>
