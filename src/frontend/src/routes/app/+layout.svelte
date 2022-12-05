<script lang="ts">
	import type { LayoutData } from './$types';
	import Layout from '$lib/components/common/Layout.svelte';
	import DropdownNav from '$lib/components/header/DropdownNav.svelte';
	import NavButton from '$lib/components/header/NavButton.svelte';
	import { logout } from '$lib/stores/tasks';
	
	export let data: LayoutData;



	// if ($authStore !== AuthState.Registered) {
	// 	goto("/");
	// }
	// syncAuth();
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
