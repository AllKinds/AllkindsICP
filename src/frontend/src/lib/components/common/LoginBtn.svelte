<script lang="ts">
  import { logout, login } from '$lib/stores/tasks';
	import { authStore } from '$lib/stores';
	import { AuthState } from '$lib/stores/types';
</script>

<a 
  class=" hover:bg-slate-300 dark:hover:bg-slate-600 w-fit decoration-transparent rounded-md px-2 font-semibold cursor-pointer"
  href={null}
  on:click={$authStore === AuthState.LoggedIn || $authStore === AuthState.Registered ? logout : login}
>
  {#if $authStore === AuthState.LoggedIn || $authStore === AuthState.Registered}
    Logout
  {:else}
    Login
  {/if}
</a>