<script lang="ts">
	import { login, syncAuth } from '$lib/stores/auth';
	import Layout from '$lib/components/common/Layout.svelte';
	import type { LayoutData } from './$types';
	import DropdownNav from '$lib/components/header/DropdownNav.svelte';
	import NavButton from '$lib/components/header/NavButton.svelte';


	export let data: LayoutData;
	// layout is actually not needed because landing is a single page, but still using it for possible future additions
</script>

<Layout>
	<svelte:fragment slot="nav">
		<DropdownNav links={data} path='#'>
			<NavButton on:click={login}>login</NavButton>
		</DropdownNav>
	</svelte:fragment>
	<slot slot="main"/>
</Layout>

	
		



