<script lang="ts">
	import { logout, actor, syncAuth } from '$lib/stores/auth';
	import Button from '$lib/components/common/Button.svelte';
	import { goto } from '$app/navigation';
	import BorderBox from '$lib/components/common/BorderBox.svelte';
	import { RootState, rootStore } from '$lib/stores/stores';


	//import update profile call from +page.ts?

	async function submit() {
		rootStore.set(RootState.App)
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