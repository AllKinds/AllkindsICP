<script lang="ts">
	import { logout, actor, syncAuth } from '$lib/stores/auth';
	import Button from '$lib/components/common/Button.svelte';
	import { goto } from '$app/navigation';
	import BorderBox from '$lib/components/common/BorderBox.svelte';
	import { RegiState, regiStore } from '$lib/stores/stores';
	import { z } from 'zod';

	//import update profile call from +page.ts?

	async function submit() {
		regiStore.set(RegiState.Finished);
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
	<h2>Setup your profile</h2>
	<span>You can also do this later</span>
	<BorderBox fill="brand-gradient-br">
		<label for="email" value="Email" />
		<input type="text" id="email" class="bg-slate-600 w-56 p-1 rounded-md" />
	</BorderBox>
	<div class="w-fit h-fit mx-auto">
		<Button on:click={submit}>Update Profile</Button>
	</div>
</div>
