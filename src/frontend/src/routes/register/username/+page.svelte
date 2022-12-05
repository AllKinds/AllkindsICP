<script lang="ts">
	import Button from '$lib/components/common/Button.svelte';
	import BorderBox from '$lib/components/common/BorderBox.svelte';

	import { regiStore, actor } from '$lib/stores';
	import { syncAuth } from '$lib/stores/tasks';
	import { RegiState } from '$lib/stores/types';

	let username: string;

	async function register() {
		const input = document.getElementById('username') as HTMLInputElement;
		input.disabled = true;
		console.log('username input : ', username);
		const result = await $actor.createUser(username);
		if (result.hasOwnProperty('ok')) {
			await syncAuth();
			// goto('/register/profile');
			regiStore.set(RegiState.Profile);
		} else {
			console.error(result);
		}
		input.disabled = false;
	}
	// const updateProfile = async () => {
	//   let gender: Gender = { Male: null }
	//     let user: User = {
	//       created: BigInt(0),
	//       connect: [["email@mail.com"], true],
	//       about: [[a], true],
	//       username: "shiqqqqt",
	//       gender: [[gender], false],
	//       birth: [[BigInt(0)], true]
	//     }
	//   await $actor.updateProfile(user).then((res) => console.log('res', res))
</script>

<div class="flex flex-col justify-center items-center">
	<h2>Choose a username</h2>
	<BorderBox fill="brand-gradient-br">
		<input
			type="text"
			id="username"
			class="bg-slate-600 w-56 p-1 rounded-md"
			bind:value={username}
		/>
	</BorderBox>
	<div class="w-fit h-fit mx-auto">
		<Button on:click={register}>Register</Button>
	</div>
</div>
