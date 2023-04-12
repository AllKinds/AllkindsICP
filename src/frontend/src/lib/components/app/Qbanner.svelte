<script lang="ts">
	import type { Question } from 'src/declarations/backend/backend.did';
	import Check from '$lib/assets/icons/check.svg?component';
	import X from '$lib/assets/icons/navX.svg?component';

	import ChevronDown from '$lib/assets/icons/chevronDown.svg?component';
	import { fromNullable } from '$lib/utilities';
	import { onMount } from 'svelte';

	export let q: Question;
	export let b: Boolean;
	//let expandWindow: boolean = false;
	//let userAnswer = fromNullable(a.user);
	onMount(() => {
		let banner = document.getElementById('banner');
		if (b) {
			banner?.classList.toggle('same-answer');
			console.log('same answer, should become green');
		}
	});

	//document.documentElement.classList.toggle('same-answer')}
</script>

<!-- component for Question Banner Card on a User Profile  -->
<div class="h-18 w-full flex justify-between rounded-lg padding border-main" id="banner">
	<!--<div class="flex gap-1">
		 {#if a.match.answer == true}
			<Check />
		{:else}
			<X />
		{/if} 
		
	</div>-->
	{q.question}
	<!-- <span>match: {a.match.answer}</span> -->
	<!-- <span>me: {user.answer}</span> -->
	<!-- <span>{a.match.weight}</span> -->
</div>
