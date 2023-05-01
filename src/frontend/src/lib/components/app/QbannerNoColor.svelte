<script lang="ts">
	import type { Question } from 'src/declarations/backend/backend.did';
	import { onMount } from 'svelte';

	export let q: Question;
	export let b: Boolean;

	//ugly fix to have 2 Qbanner components :/

	onMount(() => {
		let banner = document.getElementById('banner');
		if (b) {
			banner?.classList.toggle('same-answer');
		}
	});
</script>


<div
	class="h-18 w-full flex justify-between rounded-lg px-2 py-1 bg-sub text-main "
	id="banner"
>
	{q.question}
	<!-- <slot name="weight" /> -->
</div>
