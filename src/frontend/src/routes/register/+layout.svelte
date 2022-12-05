<script lang="ts">
	import Layout from '$lib/components/common/Layout.svelte';
	import DropdownNav from '$lib/components/header/DropdownNav.svelte';
	import NavButton from '$lib/components/header/NavButton.svelte';
	import { logout } from '$lib/stores/auth';
	import { goto } from '$app/navigation';
	import { RegiState, regiStore } from '$lib/stores/stores';
	import { onMount } from 'svelte';

	regiStore.set(RegiState.Username);

	$: {
		//RegiState.Username is not used here since page is default and alrdy called in root layout
		if ($regiStore === RegiState.Profile) {
			goto('/register/profile');
		} else if ($regiStore === RegiState.Finished) {
			goto('/register/finished');
		}
	}
</script>

<Layout>
	<svelte:fragment slot="nav">
		<DropdownNav links={undefined} path={null}>
			<NavButton on:click={logout}>logout</NavButton>
		</DropdownNav>
	</svelte:fragment>

	<svelte:fragment slot="main">
		<slot />
	</svelte:fragment>
</Layout>
