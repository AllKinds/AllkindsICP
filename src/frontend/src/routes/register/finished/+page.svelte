<script lang="ts">
	import { rootStore } from '$lib/stores/';
	import { RootState } from '$lib/stores/types';

	async function submit() {
		rootStore.set(RootState.App);
	}
</script>

<div class="flex flex-col justify-center items-center">
	<h2>Well done!</h2>
	<span>Profile finished</span>
	<div class="w-fit h-fit mx-auto">
		<div class="fancy-btn-border">
			<button on:click={submit} class="fancy-btn">Continue</button>
		</div>
	</div>
</div>
