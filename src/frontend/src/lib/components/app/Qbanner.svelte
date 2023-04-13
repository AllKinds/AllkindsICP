<script lang="ts">
	import type { Question } from 'src/declarations/backend/backend.did';
	import { onMount } from 'svelte';

	export let q: Question;
	export let b: Boolean;

	onMount(() => {
		let banner = document.getElementById('banner');
		if (b) {
			banner?.classList.toggle('same-answer');
		}
	});
</script>

<!-- component for Question Banner Card on a User Profile  -->
<div class="h-18 w-full flex justify-between rounded-lg padding border-main" id="banner">
	{q.question}
	<!-- <slot name="weight" /> -->
</div>
