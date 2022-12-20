<script lang="ts">
	import Layout from '$lib/components/common/Layout.svelte';
	import type { LayoutData } from './$types';
	import DropdownNav from '$lib/components/nav/DropdownNav.svelte';

	export let data: LayoutData;
	// layout is actually not needed because landing is a single page, but still using it for possible future additions
</script>

<Layout headerBg={'bg-transparant'}>
	<svelte:fragment slot="nav">
		<DropdownNav {data} />
	</svelte:fragment>
	<slot slot="main" />
</Layout>
