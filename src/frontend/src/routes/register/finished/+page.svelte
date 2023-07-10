<script lang="ts">
	import { rootStore } from '$lib/stores/';
	import { RootState } from '$lib/stores/types';

	async function submit() {
		rootStore.set(RootState.App);
	}
</script>

<div class="flex flex-col justify-center items-center">
	<h2>Well done!</h2>
	<span><li>Ask Yes/No questions and answer other people's questions.
		<li>Use +/- to indicate the importance of the question. Earn diamonds by creating questions.
		<li>Search for people that resonate the most (or the least).
		<li>Reach out to each other using emails.</span>
	<div class="w-fit h-fit mx-auto">
		<div class="fancy-btn-border">
			<button on:click={submit} class="fancy-btn">Continue</button>
		</div>
	</div>
</div>
