<script lang="ts">
	import type { LayoutData } from './$types';
	import Layout from '$lib/components/common/Layout.svelte';
	import DropdownNav from '$lib/components/header/DropdownNav.svelte';
	import NavButton from '$lib/components/header/NavButton.svelte';

	export let data: LayoutData;

	import { logout, syncAuth } from '$lib/stores/auth';
	import { onDestroy } from 'svelte';

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
