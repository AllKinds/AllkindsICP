<script lang="ts">
	import type { LayoutData } from './$types';
	import Layout from '$lib/components/common/Layout.svelte';
	import SidepanelNav from '$lib/components/nav/SidepanelNav.svelte';
	import Nav from '$lib/components/nav/Nav.svelte';
	
	export let data: LayoutData;

</script>

		<Layout headerBg={'dark:bg-gradient-to-r dark:from-slate-800/90 dark:to-slate-800 bg-slate-200'}>
			<svelte:fragment slot="nav">
				<SidepanelNav {data} />
			</svelte:fragment>

			<svelte:fragment slot="main">
				<div class="flex flex-row justify-center mt-10 gap-5">

					<!-- <div class="dark:bg-slate-800 bg-slate-100 h-screen w-56 rounded-lg max-xl:hidden">
					</div> -->

					<div class="bg-gradient-to-b from-DF-blue via-DF-red to-DF-yellow w-full rounded-lg ">
						<div class="dark:bg-slate-800/95 h-full bg-slate-200 rounded-lg">
							<slot />
						</div>
					</div>

					<div class="h-screen w-44 mx-auto max-xl:hidden rounded-lg">
						<Nav {data} path=""/>
					</div>
				
				</div>
				
			</svelte:fragment>
		</Layout>
