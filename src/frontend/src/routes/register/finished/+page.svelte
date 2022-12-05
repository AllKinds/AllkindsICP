<script lang="ts">
	import Button from '$lib/components/common/Button.svelte';
	import { rootStore } from '$lib/stores';
	import { RootState } from '$lib/stores/types';

	//import update profile call from +page.ts?

	async function submit() {
		rootStore.set(RootState.App);
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
	<h2>Well done!</h2>
	<span>Profile finished</span>
	<div class="w-fit h-fit mx-auto">
		<Button on:click={submit}>Continue</Button>
	</div>
</div>
