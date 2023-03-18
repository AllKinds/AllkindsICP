<script lang="ts">
	import { logout, login } from '$lib/stores/tasks/';
	import { authStore } from '$lib/stores/';
	import { AuthState } from '$lib/stores/types';
	import Logout from '$lib/assets/icons/logout.svg?component';
</script>

<a
	class="hover:bg-zinc-300/50 dark:hover:bg-zinc-700/50 w-fit decoration-transparent rounded-md px-1 font-semibold cursor-pointer flex"
	href={null}
	on:click={$authStore === AuthState.LoggedIn || $authStore === AuthState.Registered
		? logout
		: login}
>
	<Logout class="w-6 mr-1 mt-1 -ml-1" />
	{#if $authStore === AuthState.LoggedIn || $authStore === AuthState.Registered}
		Logout
	{:else}
		Login
	{/if}
</a>
