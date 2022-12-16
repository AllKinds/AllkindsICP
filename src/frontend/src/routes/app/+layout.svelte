<script lang="ts">
	import type { LayoutData } from './$types';
	import Layout from '$lib/components/common/Layout.svelte';
	import SidepanelNav from '$lib/components/header/SidepanelNav.svelte';
	import { sidepanelToggle } from '$lib/stores';
	import BorderBox from '$lib/components/common/BorderBox.svelte';
	
	//export let data: LayoutData;




	// onMount( () => {
	// 	syncAuth()
	// })
</script>
<div class="flex flex-row">
	<div class="grow">
		<Layout>
			<svelte:fragment slot="nav">
				<SidepanelNav />
			</svelte:fragment>

			<svelte:fragment slot="main">
				<slot />
			</svelte:fragment>
		</Layout>
	</div>
{#if $sidepanelToggle}
<div class="bg-slate-900 h-screen w-80 absolute right-0" on:mouseleave={() => sidepanelToggle.set(!$sidepanelToggle)} >

</div>
{/if}
</div>