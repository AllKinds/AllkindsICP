<script lang="ts">
	import type { Question } from 'src/declarations/backend/backend.did';
	import { onMount } from 'svelte';

	export let q: Question;
	export let b: Boolean;

	$: hue = Number(q.color);
	$: cssVariables = {
		'primary-color': `hsl(${hue} 100% 70%)`,
		'secondary-color': `hsl(${hue} 100% 60%)`
	};

	$: styleValues = Object.entries(cssVariables)
		.map(([key, value]) => `--${key}:${value}`)
		.join(';');

	onMount(() => {
		let banner = document.getElementById('banner');
		if (b) {
			banner?.classList.toggle('same-answer');
		}
	});
</script>

<!-- component for Question Banner Card on a User Profile  -->
<div style={styleValues} class="h-18 w-full flex justify-between rounded-lg padding border-main bg-fancy text-zinc-900" id="banner">
	{q.question}
	<!-- <slot name="weight" /> -->
</div>
