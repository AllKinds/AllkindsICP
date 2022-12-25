<script lang="ts">
	import type { LayoutData } from './$types';
	import Layout from '$lib/components/common/Layout.svelte';
	import SidepanelNav from '$lib/components/nav/SidepanelNav.svelte';
	import Nav from '$lib/components/nav/Nav.svelte';
	import Home from '$lib/assets/icons/home.svg?component'
	import Cogwheel from '$lib/assets/icons/cogwheel.svg?component'
	import Users from '$lib/assets/icons/users.svg?component'
	import { goto } from '$app/navigation';
	
	export let data: LayoutData;

</script>

<Layout headerBg={'dark:bg-gradient-to-r dark:from-slate-800/90 dark:to-slate-800 bg-slate-200'}>
	<svelte:fragment slot="nav">
		<SidepanelNav {data} />
	</svelte:fragment>

	<svelte:fragment slot="main">
		<div class="flex flex-row justify-center mt-8 gap-5">

			<!-- <div class="dark:bg-slate-800 bg-slate-100 h-screen w-16 rounded-lg max-sm:hidden flex flex-col items-center gap-4 py-5">
				left sided column, possible for menu icons 
				<Home class="iconbtn" />
				<Users class="iconbtn"/>
				<Cogwheel class="iconbtn"/>
			</div> -->

			<div class="bg-gradient-to-b from-DF-blue via-DF-red to-DF-yellow h-fit w-full rounded-lg">
				<div class="dark:bg-slate-800/95 bg-slate-200 h-screen rounded-lg p-2 md:p-5">
					<slot />
				</div>
			</div>

			<div class="h-screen w-44 mx-auto max-xl:hidden rounded-lg">
				<Nav {data} path=""/>
			</div>
		
		</div>
	</svelte:fragment>
	
</Layout>

<!--<div class="flex bg-slate-800 w-full h-14 fixed bottom-0 sm:hidden rounded-t-lg">
		 left sided col replacement for mobile view, is sticky to bottom
</div> -->
