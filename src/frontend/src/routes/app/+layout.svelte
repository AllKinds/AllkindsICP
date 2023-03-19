<script lang="ts">
	import type { LayoutData } from './$types';
	import Layout from '$lib/components/common/Layout.svelte';
	import SidepanelNav from '$lib/components/nav/SidepanelNav.svelte';
	import Nav from '$lib/components/nav/Nav.svelte';
	import Home from '$lib/assets/icons/home.svg?component';
	import Cogwheel from '$lib/assets/icons/cogwheel.svg?component';
	import Users from '$lib/assets/icons/users.svg?component';
	import User from '$lib/assets/icons/user.svg?component';
	import GlobeAlt from '$lib/assets/icons/globe-alt.svg?component';
	import { goto } from '$app/navigation';

	export let data: LayoutData;
</script>

<Layout>
	<!-- right sided main app nav -->
	<svelte:fragment slot="nav">
		<SidepanelNav {data} />
	</svelte:fragment>

	<svelte:fragment slot="main">
		<div class="flex flex-row justify-center mt-8 gap-4">
			<!-- left sided col, possible for menu icon shortcuts  -->
			<!-- <div
				class="sticky top-16 h-fit rounded-lg max-sm:hidden flex flex-col items-center gap-4"
			>
				<a href="/app/home"><Home class="iconbtn" /></a>
				<a href="/app/people"><Users class="iconbtn" /></a>
				<a href="/app/profile"><User class="iconbtn" /></a>
				<a href="/app/settings"><Cogwheel class="iconbtn" /></a>
			</div> -->

			<!-- main content -->
			<div class=" h-fit w-full rounded-lg mt-1 min-h-screen">
				<div class="rounded-lg ">
					<slot />
				</div>
			</div>

			<div class="bg-main sticky top-16 h-fit w-44 mx-auto max-xl:hidden rounded-lg">
				<Nav {data} path="" />
			</div>
		</div>
	</svelte:fragment>
</Layout>

<!-- menu shortcuts sticky to bottom , left sided col replacement for mobile view -->
<!-- TEMP FIX ,, TODO : generate from LayoutData-->
<div class="flex w-full py-1 fixed bottom-0 sm:hidden rounded-t-lg justify-evenly">
	<a href="/app/home"><Home class="w-10 sub-btn" /></a>
	<a href="/app/connect"><GlobeAlt class="w-10 sub-btn" /></a>
	<a href="/app/friends"><Users class="w-10 sub-btn" /></a>
	<a href="/app/profile"><User class="w-10 sub-btn" /></a>
	<a href="/app/settings"><Cogwheel class="w-10 sub-btn" /></a>
</div>
