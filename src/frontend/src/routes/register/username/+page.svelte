<script lang="ts">
	import Spinner from '$lib/components/common/Spinner.svelte';
	import { regiStore, actor } from '$lib/stores/';
	import { syncAuth } from '$lib/stores/tasks/';
	import { styleStore } from '$lib/stores/tasks/colorSelect';
	import { RegiState } from '$lib/stores/types';

	let username: string;
	let pending: boolean = false;

	async function register() {
		pending = true;
		console.log('username input : ', username);
		const result = await $actor.createUser(username);
		if (result.hasOwnProperty('ok')) {
			await syncAuth();
			// goto('/register/profile');
			regiStore.set(RegiState.Profile);
		} else {
			console.error(result);
		}
		pending = false;
	}
</script>

<div style={$styleStore} class="flex flex-col justify-center items-center">
	<h2>Choose a username</h2>
	<div class="flex p-2">
		<div
			class="flex flex-col p-0.5 rounded-lg bg-gradient-to-br from-DF-blue via-DF-red to-DF-yellow"
		>
			<input
				type="text"
				disabled={pending}
				id="username"
				class="bg-slate-600 w-56 p-1 rounded-md outline-none"
				bind:value={username}
			/>
		</div>
	</div>
	<div class="w-fit h-fit mx-auto">
		<div class="fancy-btn-border">
			<button on:click={register} class="fancy-btn">
				{#if pending}
					<Spinner />
				{:else}
					Register
				{/if}
			</button>
		</div>
	</div>
</div>
