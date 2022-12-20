<script lang="ts">
	import type { LayoutData } from './$types';
	import Layout from '$lib/components/common/Layout.svelte';
	import SidepanelNav from '$lib/components/header/SidepanelNav.svelte';

	import BorderBox from '$lib/components/common/BorderBox.svelte';
	
	export let data: LayoutData;
</script>
<div class="flex flex-row dark:bg-slate-900 bg-slate-200">
	<div class="grow">
		<Layout headerBg={'dark:bg-gradient-to-r dark:from-slate-800 dark:to-slate-800 bg-slate-100'}>
			<svelte:fragment slot="nav">
				<SidepanelNav links={data} path="" />
			</svelte:fragment>

			<svelte:fragment slot="main">
				<slot />
			</svelte:fragment>
		</Layout>
	</div>
	

</div>