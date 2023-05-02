<script lang="ts">
	import '../../../app.postcss';
	import { browser } from '$app/environment';
	import { goto } from '$app/navigation';
	import { rootStore, authStore, user, actor } from '$lib/stores/';
	import { RootState, AuthState } from '$lib/stores/types';
	import { onDestroy, onMount } from 'svelte';
	import { logout, syncAuth } from '$lib/stores/tasks';

	$: {
		//can be changed in future to make landing accessible while being logged in
		if ($rootStore === RootState.Landing || $authStore === AuthState.LoggedOut) {
			goto('/landing');
		} else if ($rootStore === RootState.Register || $authStore === AuthState.LoggedIn) {
			goto('/register/username');
		} else if ($rootStore === RootState.App || $authStore === AuthState.Registered) {
			goto('/app/home');
		}
	}
	// // make user logout onDestroy component
	// onDestroy(() => {
	// 	logout();
	// });
	// onMount(() => {
	// 	syncAuth();
	// })
</script>

{#if browser}
	<slot />
{:else}
	{console.error('Not in a browser!')}
{/if}
