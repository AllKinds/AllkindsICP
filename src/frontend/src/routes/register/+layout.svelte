<script lang="ts">
	import Layout from '$lib/components/common/Layout.svelte';
	import DropdownNav from '$lib/components/header/DropdownNav.svelte';
	import { goto } from '$app/navigation';	
	import { logout } from '$lib/stores/tasks';
	import { regiStore } from '$lib/stores';
	import { RegiState  } from '$lib/stores/types';

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
		<DropdownNav links={undefined} path={null} />
	</svelte:fragment>

	<svelte:fragment slot="main">
		<slot />
	</svelte:fragment>
</Layout>
