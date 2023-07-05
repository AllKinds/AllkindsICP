<script lang="ts">
	import { rootStore } from '$lib/stores/';
	import { RootState } from '$lib/stores/types';

	async function submit() {
		rootStore.set(RootState.App);
	}
</script>

<div class="flex flex-col justify-center items-center">
	<h2>Well done!</h2>
	<span class="text-center"><li>You will see questions from other people and can ask your own.
			<li>Your responses will be never shown in public so you can be sincere.
			<li>Upon your answers Allkinds will find those people who's resonate with you the most (or the least).
			<br><br>Good luck in finding 'the right people'!
				<div class="w-fit h-fit mx-auto">
		<div class="fancy-btn-border">
			<button on:click={submit} class="fancy-btn">Start</button>
		</div>
	</div>
</div>
