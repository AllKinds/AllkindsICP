<script lang="ts">
	import Layout from '$lib/components/common/Layout.svelte';
	import DropdownNav from '$lib/components/nav/DropdownNav.svelte';
	import { goto } from '$app/navigation';
	import { regiStore } from '$lib/stores/index';
	import { RegiState } from '$lib/stores/types';

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

<Layout headerBg={'bg-transparant'}>
	<svelte:fragment slot="nav">
		<DropdownNav data={undefined} />
	</svelte:fragment>

	<svelte:fragment slot="main">
		<slot />
	</svelte:fragment>
</Layout>
