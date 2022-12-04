<script lang="ts">
	import '../../../app.postcss';
	import { browser } from '$app/environment';
	import { goto } from '$app/navigation';
	import { AuthState, authStore, user, actor, login, syncAuth, logout } from '$lib/stores/auth';
	import { onDestroy } from 'svelte';
	import { RegiState, regiStore, RootState, rootStore } from '$lib/stores/stores';


	$: {
		//can be changed in future to make landing accessible while being logged in
		if ($rootStore === RootState.Landing || $authStore === AuthState.LoggedOut) {
			goto('/');
		} else if ($rootStore === RootState.Register || $authStore === AuthState.LoggedIn) {
			goto('/register/username');
		} else if ($rootStore === RootState.App || $authStore === AuthState.Registered) {
			goto('/app/dev');
			//temporary to dev
		}
	}

	console.log('user:', {$user})

// // make user logout onDestroy component
// 	onDestroy( () => {
// 		logout()
// 	})
</script>

{#if browser}
	<!-- authStore: {$authStore}<br>
	user: {$user}<br>
	actor: {$actor}<br> -->

	<!-- {#if $authStore === AuthState.LoggedOut}
		{goto("/")}
	{:else if $authStore === AuthState.LoggedIn}
		
		{goto("/register")}
	{:else if $authStore === AuthState.Registered}
		{goto("/app/questions")}
	{/if} -->	
		<slot />
{:else}
	{console.error('Not in a browser!')}
{/if}